//
//  LexAn.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class LexAn: LexicalAnalyzer {
  let inputStream: InputStream
  
  private var currentLocation = Location(row: 1, column: 1)
  private var bufferCharacter: Character?
  
  init(inputStream: InputStream) {
    self.inputStream = inputStream
  }
  
  func nextSymbol() -> Symbol {
    guard let symbol = parseSymbol() else {
      let symbol = Symbol(token: .eof, lexeme: "$", position: Position(startLocation: currentLocation,
                                                                           endLocation: Location(row: currentLocation.row,
                                                                                                 column: currentLocation.column + 1)))
      return symbol
    }
    return symbol
  }
}

extension LexAn: Sequence {
  struct Iterator: IteratorProtocol {
    let lexan: LexAn
    private var didEnd = false
    
    init(lexan: LexAn) {
      self.lexan = lexan
    }
    
    mutating func next() -> Symbol? {
      guard !didEnd else { return nil }
      let symbol = lexan.nextSymbol()
      didEnd = symbol.token == .eof
      return symbol
    }
  }
  
  func parseSymbol() -> Symbol? {
    while let character = nextCharacter() {
      if character == " " { continue }
      if character == "\n" {
        currentLocation = Location(row: currentLocation.row + 1, column: 1)
        continue
      }
      if character == "\t" {
        currentLocation = Location(row: currentLocation.row, column: currentLocation.column + 4)
        continue
      }
      if notLegalCharacter(character) {
        return Symbol(token: .invalidCharacter, lexeme: "\(character)", position: position(count: 1))
      }
      
      //////////////////////////////
      
      if isDoubleQuote(character) {
        return parseStringConstant()
      }
      
      if isOperator(character) {
        return parseOperatorOrComment(character)
      }
      
      bufferCharacter = character
      
      if isNumeric(character) {
        return parseNumericConstant()
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
  func parseStringConstant() -> Symbol {
    var lexeme = ""
    while let character = nextCharacter() {
      if character == "\"" {
        let newPosition = position(count: lexeme.count + 2)
        return Symbol(token: .stringConstant, lexeme: lexeme, position: newPosition)
      } else {
        lexeme.append(character)
      }
    }
    return Symbol(token: .nonEscapedStringConstant, lexeme: lexeme, position: position(count: lexeme.count + 1))
  }
  
  func parseOperatorOrComment(_ char: Character) -> Symbol? {
    func parseMultilineComment() -> Symbol? {
      while let character = nextCharacter() {
        if character == "*", let next = nextCharacter(), next == ")" {
          return parseSymbol()
        }
      }
      return nil
    }
    
    if let nextCharacter = nextCharacter() {
      let lexeme = "\(char)\(nextCharacter)"
      if let compositeOperator = LexAn.compositeOperators[lexeme] {
        let symbolPosition = position(count: 2)
        return Symbol(token: compositeOperator, lexeme: lexeme, position: symbolPosition)
      } else if lexeme == "(*" {
        return parseMultilineComment()
      } else if char == nextCharacter && (char == ":" || char == "|" || char == "=") {
        // TODO: - this is an ad-hoc fix
        return parseIdentifierOrReservedKeyword(lexeme: lexeme)
      } else {
        bufferCharacter = nextCharacter
      }
    }
    
    let symbolPosition = position(count: 1)
    return Symbol(token: LexAn.operators[char]!, lexeme: String(char), position: symbolPosition)
  }
  
  func parseNumericConstant() -> Symbol {
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
    return Symbol(token: tokenType, lexeme: lexeme, position: newPosition)
  }
  
  func parseIdentifierOrReservedKeyword(lexeme: String = "") -> Symbol {
    var lexeme = lexeme
    
    func isLegal(char: Character, lexeme: String) -> Bool {
      if let lastChar = lexeme.last {
        if isLegalCharacterForSymbolicIdentifier(lastChar) {
          return isLegalCharacterForSymbolicIdentifier(char)
        }
        return isLegalCharacterForAlphanumbericIdentifier(char)
      }
      return isLegalCharacterForAlphanumbericIdentifierWhenFirst(char) || isLegalCharacterForSymbolicIdentifier(char)
    }
    
    func tokenType() -> TokenType {
      if let keyword = LexAn.keywords[lexeme] { return keyword }
      if let logicalConstant = LexAn.booleanConstants[lexeme] { return logicalConstant }
      return .identifier
    }
    
    while let character = nextCharacter() {
      if isLegal(char: character, lexeme: lexeme) {
        lexeme.append(character)
      } else {
        bufferCharacter = character
        break
      }
    }
    
    let newPosition = position(count: lexeme.count)
    return Symbol(token: tokenType(), lexeme: lexeme, position: newPosition)
  }
}

private extension LexAn {
  func isLegalCharacterForSymbolicIdentifier(_ char: Character) -> Bool {
    return LexAn.symbolicIdentifierCharacterSet.contains(char)
  }
  
  func isLegalCharacterForAlphanumbericIdentifier(_ char: Character) -> Bool {
    return
      isLegalCharacterForAlphanumbericIdentifierWhenFirst(char) ||
      isUnderscore(char) ||
      isPrime(char) ||
      isNumeric(char)
  }
  
  func isLegalCharacterForAlphanumbericIdentifierWhenFirst(_ char: Character) -> Bool {
    return isAlphabet(char)
  }
  
  func isLegalForSymbolicIdentifier(_ char: Character) -> Bool {
    return LexAn.symbolicIdentifierCharacterSet.contains(char)
  }
  
  func isOperator(_ char: Character) -> Bool {
    return LexAn.operators[char] != nil
  }
  
  func isDoubleQuote(_ char: Character) -> Bool {
    return char == "\""
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
  
  func isPrime(_ char: Character) -> Bool {
    return char == "'"
  }
  
  func isWhitespace(_ char: Character) -> Bool {
    return char == " " || char == "\n" || char == "\t"
  }
  
  func notLegalCharacter(_ char: Character) -> Bool {
    return char == "."
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
    ["=": .assign,
     "(": .leftParent,
     ")": .rightParent,
     "[": .leftBracket,
     "]": .rightBracket,
     "{": .leftBrace,
     "}": .rightBrace,
     ",": .comma,
     ";": .semicolon,
     ":": .colon,
     "|": .pipe,
     "_": .wildcard,]
  
  private static let compositeOperators: [String: TokenType] =
    ["=>": .darrow,
     "->": .darrow,]
  
  private static let keywords: [String: TokenType] =
    ["mod": .keywordModulo,
     "not": .keywordNot,
     "abstype": .keywordAbstype,
     "and": .keywordAnd,
     "andalso": .keywordAndalso,
     "as": .keywordAs,
     "case": .keywordCase,
     "datatype": .keywordDatatype,
     "do": .keywordDo,
     "else": .keywordElse,
     "end": .keywordEnd,
     "exception": .keywordException,
     "fn": .keywordFn,
     "fun": .keywordFun,
     "handle": .keywordHandle,
     "if": .keywordIf,
     "in": .keywordIn,
     "infix": .keywordInfix,
     "infixr": .keywordInfixr,
     "let": .keywordLet,
     "local": .keywordLocal,
     "nonfix": .keywordNonfix,
     "of": .keywordOf,
     "op": .keywordOp,
     "open": .keywordOpen,
     "orelse": .keywordOrelse,
     "raise": .keywordRaise,
     "rec": .keywordRec,
     "then": .keywordThen,
     "type": .keywordType,
     "val": .keywordVal,
     "with": .keywordWith,
     "withtype": .keywordWithtype,
     "while": .keywordWhile]
  
  private static let booleanConstants: [String: TokenType] =
    ["true": .logicalConstant,
     "false": .logicalConstant]
  
  private static let symbolicIdentifierCharacterSet = "!%&$#+-/:<=>?@\\~‘^|*"
}
