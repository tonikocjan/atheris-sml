//
//  SynAn.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class SynAn: SyntaxParser {
  enum Error: Swift.Error {
    case syntaxError(String)
  }
  
  let lexan: LexicalAnalyzer
  let logger: LoggerProtocol
  let shouldDumpAst: Bool
  private var symbol: Symbol
  
  init(lexan: LexicalAnalyzer, logger: LoggerProtocol, shouldDumpAst: Bool) {
    self.lexan = lexan
    self.logger = logger
    self.shouldDumpAst = shouldDumpAst
    self.symbol = lexan.nextSymbol()
  }
  
  func parse() throws -> AstNode {
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
    if symbol.token == .eof { return [binding] }
    let newBinding = try parseBinding()
    return [binding] + (try parseBindings_(binding: newBinding))
  }
}

private extension SynAn {
  func parseValBinding() throws -> AstValBinding {
    guard symbol.token == .keywordVal else { throw reportError("expected `val`", symbol.position)}
    let startingPosition = symbol.position
    nextSymbol()
    let pattern = try parsePattern()
    let expression = try parseExpression()
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
    switch symbol.token {
    case .wildcard:
      nextSymbol()
      return AstWildcardPattern(position: symbol.position)
    case .identifier:
      nextSymbol()
      let type = symbol.token == .colon ? try parseType() : nil
      return AstIdentifierPattern(position: symbol.position, name: symbol.lexeme, type: type)
    case .leftParent:
      return try parseTuplePattern()
    case .leftBrace:
      return try parseRecordPattern()
    default:
      throw reportError("invalid token, unable to parse pattern", symbol.position)
    }
  }
  
  func parseTuplePattern() throws -> AstTuplePattern {
    guard symbol.token == .leftParent else { throw reportError("expected `(`", symbol.position) }
    let startingPosition = symbol.position
    let pattern = try parsePattern()
    let patterns = try parseTuplePattern_(pattern: pattern)
    guard symbol.token == .rightParent else { throw reportError("expected `)`", symbol.position) }
    nextSymbol()
    return AstTuplePattern(position: startingPosition + symbol.position,
                           patterns: patterns)
  }
  
  func parseTuplePattern_(pattern: AstPattern) throws -> [AstPattern] {
    guard symbol.token == .comma else { return [pattern] }
    let newPattern = try parsePattern()
    return [pattern] + (try parseTuplePattern_(pattern: newPattern))
  }
  
  func parseRecordPattern() throws -> AstRecordPattern {
    throw NSError()
  }
}

private extension SynAn {
  func parseType() throws -> AstType {
    throw NSError()
  }
}

private extension SynAn {
  func parseExpression() throws -> AstExpression {
    throw NSError()
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
    return Error.syntaxError("Syntax error [\(position.description)]: " + errorMessage)
  }
}
