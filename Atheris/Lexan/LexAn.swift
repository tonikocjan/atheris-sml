//
//  LexAn.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class LexAn: LexicalAnalyzer {
  enum Error: Swift.Error {
    case stringConstantNotClosed
    
    var localizedDescription: String {
      switch self {
      case .stringConstantNotClosed:
        return "String must be closed with a `\"`!"
      }
    }
  }
  
  let inputStream: InputStream
  
  private var currentLocation = Location(row: 1, column: 1)
  private var bufferCharacter: Character?
  private var previousSymbol: TokenType = .eof
  
  init(inputStream: InputStream) {
    self.inputStream = inputStream
  }
  
  func nextSymbol() -> Symbol {
    guard let symbol = parseSymbol() else {
      let symbol = Symbol(tokenType: .eof, lexeme: "$", position: Position(startLocation: currentLocation,
                                                                           endLocation: Location(row: currentLocation.row,
                                                                                                 column: currentLocation.column + 1)))
      return symbol
    }
    previousSymbol = symbol.tokenType
    return symbol
  }
}

extension LexAn {
  struct Iterator: IteratorProtocol {
    let lexan: LexAn
    private var didEnd = false
    
    init(lexan: LexAn) {
      self.lexan = lexan
    }
    
    mutating func next() -> Symbol? {
      guard !didEnd else { return nil }
      let symbol = lexan.nextSymbol()
      didEnd = symbol.tokenType == .eof
      return symbol
    }
  }
  
  func parseSymbol() -> Symbol? {
    while let character = nextCharacter() {
      if character == " " { continue }
      if character == "\n" {
        return parseNewLine()
      }
      
      if character == "\"" {
        return parseStringConstant()
      }
      
      if isOperator(character) {
        return parseOperatorOrComment(character)
      }
      
      bufferCharacter = character
      
      if isNumeric(character) {
        return parseNumbericConstant()
      }
      
      return parseIdentifierOrReservedKeyword()
    }
    return nil
  }
  
  func makeIterator() -> LexAn.Iterator {
    return Iterator(lexan: self)
  }
}

private extension LexAn {
  func parseNewLine() -> Symbol? {
    guard previousSymbol != .newline else { return parseSymbol() }
    
    let newline = Symbol(tokenType: .newline, lexeme: "", position: position(count: 1))
    currentLocation = Location(row: currentLocation.row + 1, column: 1)
    return newline
  }
  
  func parseStringConstant() -> Symbol {
    var lexeme = ""
    while let character = nextCharacter() {
      if character == "\"" {
        let newPosition = position(count: lexeme.count + 2)
        return Symbol(tokenType: .stringConstant, lexeme: lexeme, position: newPosition)
      } else {
        lexeme.append(character)
      }
    }
    return Symbol(tokenType: .nonEscapedStringConstant, lexeme: lexeme, position: position(count: lexeme.count + 1))
  }
  
  func parseOperatorOrComment(_ char: Character) -> Symbol? {
    func parseSingleLineComment() -> Symbol? {
      while let character = nextCharacter() {
        if character == "\n" { return parseNewLine() }
      }
      return nil
    }
    
    func parseMultilineComment() -> Symbol? {
      while let character = nextCharacter() {
        if character == "*", let next = nextCharacter(), next == "/" {
          return parseSymbol()
        }
      }
      return nil
    }
    
    if let nextCharacter = nextCharacter() {
      let lexeme = "\(char)\(nextCharacter)"
      if let compositeOperator = LexAn.compositeOperators[lexeme] {
        let symbolPosition = position(count: 2)
        return Symbol(tokenType: compositeOperator, lexeme: lexeme, position: symbolPosition)
      } else if lexeme == "//" {
        return parseSingleLineComment()
      } else if lexeme == "/*" {
        return parseMultilineComment()
      } else {
        bufferCharacter = nextCharacter
      }
    }
    let symbolPosition = position(count: 1)
    return Symbol(tokenType: LexAn.operators[char]!, lexeme: String(char), position: symbolPosition)
  }
  
  func parseNumbericConstant() -> Symbol {
    var lexeme = ""
    var tokenType = TokenType.integerConstant
    while let character = nextCharacter() {
      if isNumeric(character) {
        lexeme.append(character)
        continue
      }
      if character == "." && tokenType == .integerConstant {
        lexeme.append(character)
        tokenType = .floatingConstant
        continue
      }
      
      bufferCharacter = character
      break
    }
    
    let newPosition = position(count: lexeme.count)
    return Symbol(tokenType: tokenType, lexeme: lexeme, position: newPosition)
  }
  
  func parseIdentifierOrReservedKeyword() -> Symbol {
    var lexeme = ""
    
    func isLegal(char: Character) -> Bool {
      if lexeme.isEmpty {
        return isLegalCharacterForIdentifierWhenFirst(char)
      }
      return isLegalCharacterForIdentifier(char)
    }
    
    func tokenType() -> TokenType {
      if let keyword = LexAn.keywords[lexeme] { return keyword }
      if let logicalConstant = LexAn.booleanConstants[lexeme] { return logicalConstant }
      return .identifier
    }
    
    while let character = nextCharacter() {
      if isLegal(char: character) {
        lexeme.append(character)
      } else {
        bufferCharacter = character
        break
      }
    }
    
    let newPosition = position(count: lexeme.count)
    return Symbol(tokenType: tokenType(), lexeme: lexeme, position: newPosition)
  }
}

private extension LexAn {
  func isLegalCharacterForIdentifier(_ char: Character) -> Bool {
    return isLegalCharacterForIdentifierWhenFirst(char) || isNumeric(char)
  }
  
  func isLegalCharacterForIdentifierWhenFirst(_ char: Character) -> Bool {
    return isAlphabet(char) || isUnderscore(char)
  }
  
  func isOperator(_ char: Character) -> Bool {
    return LexAn.operators[char] != nil
  }
  
  func isNumeric(_ char: Character) -> Bool {
    return char >= "0" && char <= "9"
  }
  
  func isAlphabet(_ char: Character) -> Bool {
    return char >= "a" && char <= "z" || char >= "A" && char <= "Z"
  }
  
  func isUnderscore(_ char: Character) -> Bool {
    return char == "_"
  }
  
  func isWhitespace(_ char: Character) -> Bool {
    return char == " " || char == "\n"
  }
}

private extension LexAn {
  func nextCharacter() -> Character? {
    if let char = bufferCharacter {
      self.bufferCharacter = nil
      return char
    }
    
    do {
      let next = try inputStream.next()
      currentLocation = Location(row: currentLocation.row, column: currentLocation.column + 1)
      return next
    } catch {
      return nil
    }
  }
  
  func position(count: Int) -> Position {
    let buffer = bufferCharacter == nil ? 0 : 1
    return Position(startLocation: Location(row: currentLocation.row,
                                            column: currentLocation.column - count - buffer),
                    endLocation: Location(row: currentLocation.row,
                                          column: currentLocation.column - buffer))
  }
  
  private static let operators: [Character: TokenType] =
    ["+": .add, "-": .subtract, "*": .multiply, "/": .divide, ".": .dot, "%": .modulo, "(": .leftParent, ")": .rightParent, "[": .leftBracket, "]": .rightBracket, "{": .leftBrace, "}": .rightBrace, ",": .comma, ";": .semicolon, ":": .colon, "&": .and, "|" : .or, "!": .not, ">": .greaterThan, "<": .lowerThan, "=": .assign]
  
  private static let compositeOperators: [String: TokenType] =
    ["==": .equal, "!=": .notEqual, ">=": .greaterThanOrEqual, "<=": .lowerThanOrEqual, "||": .or, "&&": .and]
  
  private static let keywords: [String: TokenType] =
    ["else": .keywordElse, "for": .keywordFor, "func": .keywordFun, "if": .keywordIf, "var": .keywordVar, "while": .keywordWhile, "struct": .keywordStruct, "import": .keywordImport,
     "let": .keywordLet, "null": .keywordNull, "class": .keywordClass, "in": .keywordIn, "return": .keywordReturn, "public": .keywordPublic,
     "private": .keywordPrivate, "continue": .keywordContinue, "break": .keywordBreak, "switch": .keywordSwitch, "case": .keywordCase, "default": .keywordDefault,
     "enum": .keywordEnum, "init": .keywordInit, "is": .keywordIs, "override": .keywordOverride, "as": .keywordAs, "extension": .keywordExtension, "final": .keywordFinal,
     "static": .keywordStatic, "interface": .keywordInterface, "abstract": .keywordAbstract]
  
  private static let booleanConstants: [String: TokenType] =
    ["true": .logicalConstant, "false": .logicalConstant]
}
