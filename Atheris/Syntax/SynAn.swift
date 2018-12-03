//
//  SynAn.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol AtherisError: Error {
  var errorMessage: String { get }
}

class SynAn: SyntaxParser {
  enum Error: AtherisError {
    case syntaxError(String)
    
    var errorMessage: String {
      switch self {
      case .syntaxError(let error):
        return error
      }
    }
  }
  
  let lexan: LexicalAnalyzer
  private var symbol: Symbol
  
  init(lexan: LexicalAnalyzer) {
    self.lexan = lexan
    self.symbol = lexan.nextSymbol()
  }
  
  func parse() throws -> AstBindings {
    return try parseBindings()
  }
}

private extension SynAn {
  func parseBindings() throws -> AstBindings {
    let bindings = try parseBindings_(binding: try parseBinding())
    guard let first = bindings.first, let last = bindings.last else {
      throw reportError("", symbol.position)
    }
    return AstBindings(position: first.position + last.position, bindings: bindings)
  }
  
  func parseBinding() throws -> AstBinding {
    switch symbol.token {
    case .keywordVal:
      return try parseValBinding()
    case .keywordFun:
      return try parseFunBinding()
    default:
      throw reportError("removing", symbol.position, symbol)
    }
  }
  
  func parseBindings_(binding: AstBinding) throws -> [AstBinding] {
    if expecting(.eof) { return [binding] }
    let newBinding = try parseBinding()
    return [binding] + (try parseBindings_(binding: newBinding))
  }
}

private extension SynAn {
  func parseValBinding() throws -> AstValBinding {
    guard expecting(.keywordVal) else { throw reportError("expected `val`", symbol.position)}
    let startingPosition = symbol.position
    nextSymbol()
    let pattern = try parsePattern()
    guard expecting(.assign) else { throw reportError("expected `=`", symbol.position) }
    nextSymbol()
    let expression = try parseExpression()
    guard expecting(.semicolon) else { throw reportError("expected `;`", symbol.position) }
    nextSymbol()
    return AstValBinding(position: startingPosition + expression.position,
                         pattern: pattern,
                         expression: expression)
  }
  
  func parseFunBinding() throws -> AstFunBinding {
    throw NSError()
  }
}

private extension SynAn {
  func parsePattern() throws -> AstPattern {
    let pattern = try parseAtomPattern()
    return try parsePattern_(pattern: pattern)
  }
  
  func parsePattern_(pattern: AstPattern) throws -> AstPattern {
    switch symbol.token {
    case .colon:
      nextSymbol()
      let type = try parseType()
      return AstTypedPattern(position: pattern.position + type.position, pattern: pattern, type: type)
    // TODO: ....
    default:
      return pattern
    }
  }
  
  func parseAtomPattern() throws -> AstPattern {
    switch symbol.token {
    case .wildcard:
      nextSymbol()
      return AstWildcardPattern(position: symbol.position)
    case .identifier:
      return parseIdentifierPattern()
    case .leftParent:
      return try parseTuplePattern()
    case .leftBrace:
      return try parseRecordPattern()
    default:
      throw reportError("invalid token, unable to parse pattern", symbol.position)
    }
  }
  
  func parseIdentifierPattern() -> AstIdentifierPattern {
    let identifier = symbol
    nextSymbol()
    return AstIdentifierPattern(position: identifier.position, name: identifier.lexeme)
  }
  
  func parseTuplePattern() throws -> AstTuplePattern {
    guard expecting(.leftParent) else { throw reportError("expected `(`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let pattern = try parsePattern()
    let patterns = try parseTuplePattern_(pattern: pattern)
    guard expecting(.rightParent) else { throw reportError("expected `)`", symbol.position) }
    nextSymbol()
    return AstTuplePattern(position: startingPosition + symbol.position,
                           patterns: patterns)
  }
  
  func parseTuplePattern_(pattern: AstPattern) throws -> [AstPattern] {
    guard expecting(.comma) else { return [pattern] }
    nextSymbol()
    let newPattern = try parsePattern()
    return [pattern] + (try parseTuplePattern_(pattern: newPattern))
  }
  
  func parseRecordPattern() throws -> AstRecordPattern {
    throw NSError()
  }
}

private extension SynAn {
  func parseType() throws -> AstType {
    switch symbol.token {
    case .identifier:
      let currentSymbol = symbol
      nextSymbol()
      return AstTypeName(position: currentSymbol.position,
                         name: currentSymbol.lexeme)
    case .leftParent:
      return try parseTupleType()
    default:
      throw reportError("failed to parse type", symbol.position)
    }
  }
  
  func parseTupleType() throws -> AstTupleType {
    guard expecting(.leftParent) else { throw reportError("expected `(`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let types = try parseStarSeparatedTypes()
    guard expecting(.rightParent) else { throw reportError("expected `)`", symbol.position) }
    let endingPosition = symbol.position
    nextSymbol()
    let tupleType = AstTupleType(position: startingPosition + endingPosition, types: types)
    return tupleType
  }
  
  func parseStarSeparatedTypes() throws -> [AstType] {
    let type = try parseType()
    return try parseStarSeparatedTypes_(type: type)
  }
  
  func parseStarSeparatedTypes_(type: AstType) throws -> [AstType] {
    guard expecting(.identifier), symbol.lexeme == "*" else { return [type] }
    nextSymbol()
    let newType = try parseType()
    return [type] + (try parseStarSeparatedTypes_(type: newType))
  }
}

private extension SynAn {
  func parseExpression() throws -> AstExpression {
    switch symbol.token {
    case .leftParent,
         .leftBrace,
         .leftBracket,
         .integerConstant,
         .floatingConstant,
         .logicalConstant,
         .stringConstant,
         .keywordLet:
      return try parseExpression_(expression: parseIorExpression())
    case .identifier:
      return try parseExpression_(expression: parseIorExpression())
    default:
      throw Error.syntaxError("invalid symbol")
    }
  }
  
  func parseExpression_(expression: AstExpression) throws -> AstExpression {
    return expression
  }
  
  func parseIorExpression() throws -> AstExpression {
    return try parseIorExpression_(expression: try parseAndExpression())
  }
  
  func parseIorExpression_(expression: AstExpression) throws -> AstExpression {
    switch symbol.token {
    case .keywordOrelse:
      nextSymbol()
      let newExpression = try parseCmpExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .orelse,
                                                 left: expression, right: newExpression)
      return try parseIorExpression_(expression: binaryExpression)
    default:
      return expression
    }
  }
  
  func parseAndExpression() throws -> AstExpression {
    return try parseAndExpression_(expression: try parseCmpExpression())
  }
  
  func parseAndExpression_(expression: AstExpression) throws -> AstExpression {
    switch symbol.token {
    case .keywordAndalso:
      nextSymbol()
      let newExpression = try parseCmpExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .andalso,
                                                 left: expression, right: newExpression)
      return try parseAndExpression_(expression: binaryExpression)
    default:
      return expression
    }
  }
  
  func parseCmpExpression() throws -> AstExpression {
    return try parseCmpExpression_(expression: try parseAddExpression())
  }
  
  func parseCmpExpression_(expression: AstExpression) throws -> AstExpression {
    switch symbol.lexeme {
    case "<":
      nextSymbol()
      let newExpression = try parsePrefixExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .lessThan,
                                                 left: expression, right: newExpression)
      return binaryExpression
    case ">":
      nextSymbol()
      let newExpression = try parsePrefixExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .greaterThan,
                                                 left: expression, right: newExpression)
      return binaryExpression
    case "=":
      nextSymbol()
      let newExpression = try parsePrefixExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .equal,
                                                 left: expression, right: newExpression)
      return binaryExpression
    case "<=":
      nextSymbol()
      let newExpression = try parsePrefixExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .lessThanOrEqual,
                                                 left: expression, right: newExpression)
      return binaryExpression
    case ">=":
      nextSymbol()
      let newExpression = try parsePrefixExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .greaterThanOrEqual,
                                                 left: expression, right: newExpression)
      return binaryExpression
    default:
      return expression
    }
  }
  
  func parseAddExpression() throws -> AstExpression {
    return try parseAddExpression_(expression: try parseMulExpression())
  }
  
  func parseAddExpression_(expression: AstExpression) throws -> AstExpression {
    switch symbol.token {
    case .identifier:
      switch symbol.lexeme {
      case "+":
        nextSymbol()
        let newExpression = try parseMulExpression()
        let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                   operation: .add,
                                                   left: expression, right: newExpression)
        return try parseAddExpression_(expression: binaryExpression)
      case "-":
        nextSymbol()
        let newExpression = try parseMulExpression()
        let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                   operation: .subtract,
                                                   left: expression, right: newExpression)
        return try parseAddExpression_(expression: binaryExpression)
      default:
        return expression
      }
    default:
      return expression
    }
  }
  
  func parseMulExpression() throws -> AstExpression {
    return try parseMulExpression_(expression: try parsePrefixExpression())
  }
  
  func parseMulExpression_(expression: AstExpression) throws -> AstExpression {
    switch symbol.token {
    case .identifier:
      switch symbol.lexeme {
      case "*":
        nextSymbol()
        let newExpression = try parsePrefixExpression()
        let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                   operation: .multiply,
                                                   left: expression, right: newExpression)
        return try parseMulExpression_(expression: binaryExpression)
      case "/":
        nextSymbol()
        let newExpression = try parsePrefixExpression()
        let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                   operation: .divide,
                                                   left: expression, right: newExpression)
        return try parseMulExpression_(expression: binaryExpression)
      default:
        return expression
      }
    default:
      return expression
    }
  }
  
  func parsePrefixExpression() throws -> AstExpression {
    guard expecting("~") else {
      return try parseCmpExpression_(expression: try parsePostfixExpression())
    }
    
    let startingPosition = symbol.position
    nextSymbol()
    let expression = try parsePrefixExpression()
    return AstUnaryExpression(position: startingPosition + expression.position,
                              operation: .negate,
                              expression: expression)
  }
  
  func parsePostfixExpression() throws -> AstExpression {
    return try parsePostfixExpression_(expression: try parseAtomExpression())
  }
  
  func parsePostfixExpression_(expression: AstExpression) throws -> AstExpression {
    return expression
  }
  
  func parseAtomExpression() throws -> AstExpression {
    let currentSymbol = symbol
    
    switch symbol.token {
    case .integerConstant:
      nextSymbol()
      return AstConstantExpression(position: currentSymbol.position, value: currentSymbol.lexeme, type: .int)
    case .stringConstant:
      nextSymbol()
      return AstConstantExpression(position: currentSymbol.position, value: currentSymbol.lexeme, type: .string)
    case .floatingConstant:
      nextSymbol()
      return AstConstantExpression(position: currentSymbol.position, value: currentSymbol.lexeme, type: .real)
    case .logicalConstant:
      nextSymbol()
      return AstConstantExpression(position: currentSymbol.position, value: currentSymbol.lexeme, type: .bool)
    case .identifier:
      nextSymbol()
      return AstNameExpression(position: currentSymbol.position, name: currentSymbol.lexeme)
    case .leftParent:
      let expression = try parseTupleExpression()
      guard expecting(.rightParent) else { throw reportError("expecting `)`", symbol.position) }
      nextSymbol()
      if expression.expressions.count == 1, let first = expression.expressions.first {
        return first
      }
      return expression
    default:
      throw reportError("unable to parse expression", symbol.position)
    }
  }
  
  func parseTupleExpression() throws -> AstTupleExpression {
    guard expecting(.leftParent) else {
      throw reportError("expecting `(`", symbol.position)
    }
    
    nextSymbol()
    let expressions = try parseCommaSeparatedExpressions()
    guard let first = expressions.first, let last = expressions.last else {
      throw reportError("failed to parse tuple expression", symbol.position)
    }
    return AstTupleExpression(position: first.position + last.position,
                              expressions: expressions)
  }
  
  func parseCommaSeparatedExpressions() throws -> [AstExpression] {
    let expression = try parseExpression()
    return try parseCommaSeparatedExpressions_(expression: expression)
  }
  
  func parseCommaSeparatedExpressions_(expression: AstExpression) throws -> [AstExpression] {
    guard expecting(.comma) else { return [expression] }
    nextSymbol()
    let newExpression = try parseExpression()
    return [expression] + (try parseCommaSeparatedExpressions_(expression: newExpression))
  }
}

private extension SynAn {
  @discardableResult
  func nextSymbol() -> Symbol {
    symbol = lexan.nextSymbol()
    return symbol
  }
  
  func reportError(_ error: String, _ position: Position, _ others: CustomStringConvertible...) -> Error {
    let errorMessage = error + others.map { $0.description }.joined(separator: " ")
    return Error.syntaxError("Syntax error \(position.description): " + errorMessage)
  }
  
  func expecting(_ type: TokenType) -> Bool {
    return symbol.token == type
  }
  
  func expecting(_ lexeme: String) -> Bool {
    return symbol.token == .identifier && symbol.lexeme == lexeme
  }
}
