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
  private var wildcardVarBindingsCounter = 0
  private let wildcardValBindingName = "x"
  
  init(lexan: LexicalAnalyzer) {
    self.lexan = lexan
    self.symbol = lexan.nextSymbol()
  }
  
  func parse() throws -> AstBindings {
    return try parseBindings(separated: ";", stop: .eof)
  }
}

private extension SynAn {
  func parseBindings(separated with: String, stop when: TokenType) throws -> AstBindings {
    let bindings = try parseBindings_(binding: try parseBinding(), sepearated: with, stop: when)
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
    case .keywordDatatype:
      return try parseDatatypeBinding()
    default:
      wildcardVarBindingsCounter += 1
      let expression = try parseExpression()
      return AstValBinding(position: expression.position,
                           pattern: AstIdentifierPattern(position: expression.position, name: wildcardValBindingName + String(wildcardVarBindingsCounter)),
                           expression: expression)
    }
  }
  
  func parseBindings_(binding: AstBinding, sepearated with: String, stop when: TokenType) throws -> [AstBinding] {
    guard with.isEmpty || expecting(with) else { throw reportError("expecting `\(with)`", symbol.position)}
    if !with.isEmpty { nextSymbol() }
    guard !expecting(when) else { return [binding] }
    let newBinding = try parseBinding()
    return [binding] + (try parseBindings_(binding: newBinding, sepearated: with, stop: when))
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
    return AstValBinding(position: startingPosition + expression.position,
                         pattern: pattern,
                         expression: expression)
  }
  
  func parseFunBinding() throws -> AstFunBinding {
    guard expecting(.keywordFun) else { throw reportError("expecting `fun`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let identifier = try parseIdentifierPattern()
    var cases = [AstFunBinding.Case]()
    repeat {
      let parameter = try parseAtomPattern()
      let resultType: AstType?
      if expecting(.colon) {
        nextSymbol()
        resultType = try parseAtomType()
      } else {
        resultType = nil
      }
      //      guard expecting("=") else { throw reportError("expecting `=`", symbol.position) }
      
      let body = try parseFunBody()
      cases.append(AstFunBinding.Case(parameter: parameter, body: body, resultType: resultType))
      if expecting(.pipe) {
        nextSymbol()
        let caseIdentifier = try parseIdentifierPattern()
        guard caseIdentifier.name == identifier.name else { throw Error.syntaxError("clauses do not all have same function name") }
      }
      else { break }
    } while true
    let binding = AstFunBinding(position: startingPosition + cases.last!.body.position,
                                identifier: identifier,
                                cases: cases)
    return binding
  }
  
  func parseFunBody() throws -> AstExpression {
    if expecting("=") {
      nextSymbol()
      return try parseExpression()
    }
    let pattern = try parsePattern()
    return try parseFunBody_(pattern: pattern)
  }
  
  func parseFunBody_(pattern: AstPattern) throws -> AstExpression {
    if expecting("=") {
      nextSymbol()
      let expression = try parseExpression()
      return AstAnonymousFunctionBinding(position: pattern.position + expression.position,
                                         parameter: pattern,
                                         body: expression)
    }
    let newPattern = try parsePattern()
    return AstAnonymousFunctionBinding(position: pattern.position + newPattern.position,
                                       parameter: pattern,
                                       body: try parseFunBody_(pattern: newPattern))
  }
  
  func parseParameters() throws -> [AstPattern] {
    let parameter = try parsePattern()
    return try parseParameters_(parameter: parameter)
  }
  
  func parseParameters_(parameter: AstPattern) throws -> [AstPattern] {
    guard !expecting("=") else { return [parameter] }
    let newParameter = try parsePattern()
    return [parameter] + (try parseParameters_(parameter: newParameter))
  }
  
  func parseDatatypeBinding() throws -> AstDatatypeBinding {
    guard expecting(.keywordDatatype) else { throw reportError("expecting `datatype`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let types: [AstTypeBinding]
    if expecting(.leftParent) || expecting("'") {
      types = try parseAnonymousTypeBindings()
    } else {
      types = []
    }
    let identifier = try parseIdentifierPattern()
    guard expecting("=") else { throw reportError("expecting `=`", symbol.position) }
    nextSymbol()
    let cases = try parseCases(datatypeCase: try parseCase())
    return AstDatatypeBinding(position: startingPosition + cases.last!.position,
                              name: identifier,
                              cases: cases,
                              types: types)
  }
  
  func parseCase() throws -> AstCase {
    let type: AstType?
    let identifier = try parseIdentifierPattern()
    if expecting(.keywordOf) {
      nextSymbol()
      type = try parseType()
    } else {
      type = nil
    }
    return AstCase(position: type == nil ? identifier.position : identifier.position + type!.position,
                   name: identifier,
                   associatedType: type)
  }
  
  func parseCases(datatypeCase: AstCase) throws -> [AstCase] {
    guard expecting("|") else { return [datatypeCase] }
    nextSymbol()
    let newCase = try parseCase()
    return [datatypeCase] + (try parseCases(datatypeCase: newCase))
  }
}

private extension SynAn {
  func parseAnonymousTypeBinding() throws -> AstTypeBinding {
    func parse(type: AstTypeBinding.Kind) throws -> AstTypeBinding {
      let position = symbol.position
      nextSymbol()
      let identifier = try parseIdentifierPattern()
      return AstTypeBinding(position: position + identifier.position,
                            identifier: identifier,
                            type: type)
    }
    
    switch symbol.lexeme {
    case "'":
      return try parse(type: .normal)
    case "''":
      return try parse(type: .equatable)
    default:
      throw reportError("invalid symbol", symbol.position)
    }
  }
  
  func parseAnonymousTypeBindings() throws -> [AstTypeBinding] {
    func parse() throws -> [AstTypeBinding] {
      var bindings = [AstTypeBinding]()
      while true {
        let type = try parseAnonymousTypeBinding()
        bindings.append(type)
        if symbol.token != .comma { break }
        nextSymbol()
      }
      return bindings
    }
    
    if expecting(.leftParent) {
      nextSymbol()
      let bindings = try parse()
      guard expecting(.rightParent) else { throw reportError("expecting `)`", symbol.position) }
      nextSymbol()
      return bindings
    } else {
      return try parse()
    }
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
      let type = try parseAtomType()
      return AstTypedPattern(position: pattern.position + type.position, pattern: pattern, type: type)
    case .identifier:
      switch symbol.lexeme {
      case "::":
        nextSymbol()
        let tail = try parsePattern()
        return AstListPattern(position: pattern.position + tail.position,
                              head: pattern,
                              tail: tail)
      default:
        return pattern
      }
    default:
      return pattern
    }
  }
  
  func parseAtomPattern() throws -> AstPattern {
    func constantPattern(type: AstAtomType.AtomType) -> AstConstantPattern {
      let lexeme = symbol.lexeme
      nextSymbol()
      return AstConstantPattern(position: symbol.position, value: lexeme, type: type)
    }
    
    switch symbol.token {
    case .wildcard:
      nextSymbol()
      return AstWildcardPattern(position: symbol.position)
    case .identifier:
      return try parseIdentifierPattern()
    case .leftParent:
      return try parseTuplePattern()
    case .leftBrace:
      return try parseRecordPattern()
    case .leftBracket:
      let position = symbol.position
      nextSymbol()
      guard expecting(.rightBracket) else { throw reportError("expecting `]`", symbol.position) }
      let pattern = AstEmptyListPattern(position: position + symbol.position)
      nextSymbol()
      return pattern
    case .integerConstant:
      return constantPattern(type: .int)
    case .floatingConstant:
      return constantPattern(type: .real)
    case .logicalConstant:
      return constantPattern(type: .bool)
    case .stringConstant:
      return constantPattern(type: .string)
    default:
      throw reportError("invalid token, unable to parse pattern", symbol.position)
    }
  }
  
  func parseIdentifierPattern() throws -> AstIdentifierPattern {
    let identifier = symbol
    nextSymbol()
    return AstIdentifierPattern(position: identifier.position, name: identifier.lexeme)
  }
  
  func parseTuplePattern() throws -> AstPattern {
    guard expecting(.leftParent) else { throw reportError("expected `(`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let pattern = try parsePattern()
    let patterns = try parseTuplePattern_(pattern: pattern)
    guard expecting(.rightParent) else { throw reportError("expected `)`", symbol.position) }
    nextSymbol()
    if patterns.count == 1, let first = patterns.first { return first }
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
    guard expecting(.leftBrace) else { throw reportError("expecting `{`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let recordRow = try parseRecordRow()
    throw NSError()
  }
}

private extension SynAn {
  func parseType() throws -> AstType {
    let type = try parseAtomType()
    return try parseType_(type: type)
  }
  
  func parseType_(type: AstType) throws -> AstType {
//    guard symbol.token == .identifier else { return type }
//    switch symbol.lexeme {
//    case "*":
//      return type
//    default:
//      let identifier = try parseIdentifierPattern()
//      let typeName = AstTypeConstructor(position: type.position + identifier.position,
//                                        name: identifier.name,
//                                        types: [type])
//      return try parseAtomType_(type: typeName)
    return type
  }
  
  func parseAtomType() throws -> AstType {
    let type = try parseAtomType2()
    return try parseAtomType_(type: type)
  }
  
  func parseAtomType_(type: AstType) throws -> AstType {
    guard expecting("*") else { return type }
    var types = [type]
    while expecting("*") {
      nextSymbol()
      let newType = try parseAtomType2()
      types.append(newType)
    }
    return AstTupleType(position: type.position + types.last!.position,
                        types: types)
  }
  
  func parseAtomType2() throws -> AstType {
    switch symbol.token {
    case .identifier:
      switch symbol.lexeme {
      case "'", "''":
        let anonymousType = try parseAnonymousTypeBinding()
        let typeName = AstTypeName(position: anonymousType.position,
                                   name: anonymousType.name)
        return typeName
      default:
        let currentSymbol = symbol
        nextSymbol()
        let typeName = AstTypeName(position: currentSymbol.position,
                                   name: currentSymbol.lexeme)
        return typeName
      }
    case .leftParent:
      let tuple = try parseTupleType()
      return tuple
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
    let type = try parseAtomType2()
    return try parseStarSeparatedTypes_(type: type)
  }
  
  func parseStarSeparatedTypes_(type: AstType) throws -> [AstType] {
    guard expecting(.identifier), symbol.lexeme == "*" else { return [type] }
    nextSymbol()
    let newType = try parseAtomType2()
    return [type] + (try parseStarSeparatedTypes_(type: newType))
  }
}

private extension SynAn {
  func parseExpression() throws -> AstExpression {
    switch symbol.token {
    case .keywordIf:
      return try parseIfExpression()
    case .leftParent,
         .leftBrace,
         .leftBracket,
         .integerConstant,
         .floatingConstant,
         .logicalConstant,
         .stringConstant,
         .keywordLet,
         .identifier,
         .keywordNot:
      return try parseExpression_(expression: parseIorExpression())
    case .keywordFn:
      return try parseAnonymousFunctionExpression()
    case .keywordCase:
      return try parseCaseExpression()
    default:
      throw reportError("unexpected symbol", symbol.position)
    }
  }
  
  func parseIfExpression() throws -> AstIfExpression {
    guard expecting(.keywordIf) else { throw reportError("expected `if`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let condition = try parseExpression()
    guard expecting(.keywordThen) else { throw reportError("expected `then`", symbol.position) }
    nextSymbol()
    let positiveBranch = try parseExpression()
    guard expecting(.keywordElse) else { throw reportError("expected `else`", symbol.position) }
    nextSymbol()
    let negativeBranch = try parseExpression()
    return AstIfExpression(position: startingPosition + negativeBranch.position,
                           condition: condition,
                           trueBranch: positiveBranch,
                           falseBranch: negativeBranch)
  }
  
  func parseAnonymousFunctionExpression() throws -> AstAnonymousFunctionBinding {
    guard expecting(.keywordFn) else { throw reportError("expecting `fn`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let match = try parseMatch()
    return AstAnonymousFunctionBinding(position: startingPosition + match.position,
                                       parameter: match.rules.first!.pattern,
                                       body: match.rules.first!.expression)
  }
  
  func parseMatch() throws -> AstMatch {
    let rules = try parseRules()
    guard let first = rules.first, let last = rules.last else { throw reportError("parsing match failed", symbol.position) }
    return AstMatch(position: first.position + last.position,
                    rules: rules)
  }
  
  func parseRules() throws -> [AstRule] {
    let rule = try parseRule()
    return try parseRules_(rule: rule)
  }
  
  func parseRules_(rule: AstRule) throws -> [AstRule] {
    if !expecting(.pipe) { return [rule] }
    nextSymbol()
    let newRule = try parseRule()
    return [rule] + (try parseRules_(rule: newRule))
  }
  
  func parseRule() throws -> AstRule {
    let pattern = try parsePattern()
    let associatedValue: AstPattern?
    if expecting("=>") {
      nextSymbol()
      associatedValue = nil
    } else {
      associatedValue = try parsePattern()
      guard expecting("=>") else { throw reportError("expecting `=>`", symbol.position) }
      nextSymbol()
    }
    let expression = try parseExpression()
    return AstRule(position: pattern.position + expression.position,
                   pattern: pattern,
                   associatedValue: associatedValue,
                   expression: expression)
  }
  
  func parseCaseExpression() throws -> AstCaseExpression {
    guard expecting(.keywordCase) else { throw reportError("expecting `case`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let expression = try parseExpression()
    guard expecting(.keywordOf) else { throw reportError("expecting `of`", symbol.position) }
    nextSymbol()
    let match = try parseMatch()
    return AstCaseExpression(position: startingPosition + match.position,
                             expression: expression,
                             match: match)
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
      let newExpression = try parseAddExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .lessThan,
                                                 left: expression, right: newExpression)
      return binaryExpression
    case ">":
      nextSymbol()
      let newExpression = try parseAddExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .greaterThan,
                                                 left: expression, right: newExpression)
      return binaryExpression
    case "=":
      nextSymbol()
      let newExpression = try parseAddExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .equal,
                                                 left: expression, right: newExpression)
      return binaryExpression
    case "<=":
      nextSymbol()
      let newExpression = try parseAddExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: .lessThanOrEqual,
                                                 left: expression, right: newExpression)
      return binaryExpression
    case ">=":
      nextSymbol()
      let newExpression = try parseAddExpression()
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
    func binaryExpression(operation: AstBinaryExpression.Operation) throws -> AstExpression {
      let newExpression = try parseMulExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: operation,
                                                 left: expression, right: newExpression)
      return try parseMulExpression_(expression: binaryExpression)
    }
    
    switch symbol.token {
    case .identifier:
      switch symbol.lexeme {
      case "+":
        nextSymbol()
        return try parseAddExpression_(expression: binaryExpression(operation: .add))
      case "-":
        nextSymbol()
        return try parseAddExpression_(expression: binaryExpression(operation: .subtract))
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
    func binaryExpression(operation: AstBinaryExpression.Operation) throws -> AstExpression {
      let newExpression = try parsePrefixExpression()
      let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                                 operation: operation,
                                                 left: expression, right: newExpression)
      return try parseMulExpression_(expression: binaryExpression)
    }
    
    switch symbol.token {
    case .identifier:
      switch symbol.lexeme {
      case "*":
        nextSymbol()
        return try parseMulExpression_(expression: binaryExpression(operation: .multiply))
      case "/":
        nextSymbol()
        return try parseMulExpression_(expression: binaryExpression(operation: .divide))
      case "^":
        nextSymbol()
        return try parseMulExpression_(expression: binaryExpression(operation: .concat))
      default:
        return expression
      }
    case .keywordModulo:
      nextSymbol()
      return try parseMulExpression_(expression: binaryExpression(operation: .modulo))
    default:
      return expression
    }
  }
  
  func parsePrefixExpression() throws -> AstExpression {
    switch symbol.lexeme {
    case "~":
      let startingPosition = symbol.position
      nextSymbol()
      let expression = try parsePrefixExpression()
      return AstUnaryExpression(position: startingPosition + expression.position,
                                operation: .negate,
                                expression: expression)
    case "not":
      let startingPosition = symbol.position
      nextSymbol()
      let expression = try parsePrefixExpression()
      return AstUnaryExpression(position: startingPosition + expression.position,
                                operation: .not,
                                expression: expression)
    default:
      return try parsePostfixExpression()
    }
  }
  
  func parsePostfixExpression() throws -> AstExpression {
    return try parsePostfixExpression_(expression: try parseAppendExpression())
  }
  
  func parsePostfixExpression_(expression: AstExpression) throws -> AstExpression {
    func parseFunction() throws -> AstExpression {
      let argument = try parseAtomExpression()
      
      switch expression {
      case is AstNameExpression:
        return AstFunctionCallExpression(position: expression.position + argument.position,
                                         name: (expression as! AstNameExpression).name,
                                         argument: argument)
      default:
        let call = AstAnonymousFunctionCall(position: expression.position + argument.position,
                                            function: expression,
                                            argument: argument)
        return try parsePostfixExpression_(expression: call)
      }
    }
    
    switch symbol.token {
    case .leftParent,
         .charConstant,
         .integerConstant,
         .logicalConstant,
         .floatingConstant,
         .stringConstant:
      return try parsePostfixExpression_(expression: parseFunction())
    case .identifier:
      switch symbol.lexeme {
      case "+", "-", "*", "/", "::", "<", ">", "<=", ">=", "^":
        return expression
      default:
        return try parseFunction()
      }
    default:
      return expression
    }
  }
  
  func parseAppendExpression() throws -> AstExpression {
    return try parseAppendExpression_(expression: try parseAtomExpression())
  }
  
  func parseAppendExpression_(expression: AstExpression) throws -> AstExpression {
    guard expecting("::") else { return expression }
    nextSymbol()
    let newExpression = try parseExpression()
    let binaryExpression = AstBinaryExpression(position: expression.position + newExpression.position,
                                               operation: .append,
                                               left: expression,
                                               right: newExpression)
    return binaryExpression
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
      switch symbol.lexeme {
      case "#":
        return try parseRecordSelectorExpression()
      case "~":
        return try parsePrefixExpression()
      default:
        let identifier = symbol
        nextSymbol()
        return AstNameExpression(position: identifier.position, name: identifier.lexeme)
      }
    case .leftParent:
      let expression = try parseTupleExpression()
      if expression.expressions.count == 1, let first = expression.expressions.first {
        return first
      }
      return expression
    case .keywordLet:
      return try parseLetExpression()
    case .leftBrace:
      return try parseRecordExpression()
    case .leftBracket:
      return try parseListExpression()
    default:
      throw reportError("unable to parse expression", symbol.position)
    }
  }
  
  func parseFunctionCallExpression(identifier: String) throws -> AstFunctionCallExpression {
    let argument = try parseExpression()
    let functionCall = AstFunctionCallExpression(position: argument.position,
                                                 name: identifier,
                                                 argument: argument)
    return try parseFunctionCallExpression_(functionCall: functionCall)
  }
  
  func parseFunctionCallExpression_(functionCall: AstFunctionCallExpression) throws -> AstFunctionCallExpression {
    switch symbol.token {
    case .integerConstant, .stringConstant, .floatingConstant, .logicalConstant, .identifier, .leftParent, .keywordLet:
      let newArgument = try parseExpression()
      let newFunctionCall = AstAnonymousFunctionCall(position: functionCall.position + newArgument.position,
                                                     function: functionCall,
                                                     argument: newArgument)
      return try parseFunctionCallExpression_(functionCall: newFunctionCall)
    default:
      return functionCall
    }
  }
  
  func parseTupleExpression() throws -> AstTupleExpression {
    guard expecting(.leftParent) else { throw reportError("expecting `(`", symbol.position) }
    nextSymbol()
    let expressions = try parseCommaSeparatedExpressions()
    guard expecting(.rightParent) else { throw reportError("expecting `)`", symbol.position) }
    nextSymbol()
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
  
  func parseLetExpression() throws -> AstLetExpression {
    guard expecting(.keywordLet) else { throw reportError("expected `let`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let bindings = try parseBindings(separated: "", stop: .keywordIn)
    guard expecting(.keywordIn) else { throw reportError("expecting `in`", symbol.position) }
    nextSymbol()
    let expression = try parseExpression()
    guard expecting(.keywordEnd) else { throw reportError("expecting `end`", symbol.position) }
    nextSymbol()
    return AstLetExpression(position: startingPosition + bindings.position,
                            bindings: bindings,
                            expression: expression)
  }
  
  func parseRecordExpression() throws -> AstRecordExpression {
    guard expecting(.leftBrace) else { throw reportError("expecting `{`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let rows = try parseRecordRows()
    guard expecting(.rightBrace) else { throw reportError("expecting `}`", symbol.position) }
    let endingPosition = symbol.position
    nextSymbol()
    return AstRecordExpression(position: startingPosition + endingPosition,
                               rows: rows)
  }
  
  func parseRecordRows() throws -> [AstRecordRow] {
    let row = try parseRecordRow()
    return try parseRecordRows_(row: row)
  }
  
  func parseRecordRows_(row: AstRecordRow) throws -> [AstRecordRow] {
    if expecting(.rightBrace) { return [row] }
    guard expecting(.comma) else { throw reportError("expecting `,`", symbol.position) }
    nextSymbol()
    let newRow = try parseRecordRow()
    return [row] + (try parseRecordRows_(row: newRow))
  }
  
  func parseRecordRow() throws -> AstRecordRow {
    let identifier = try parseIdentifierPattern()
    guard expecting("=") else { throw reportError("expecting `=`", symbol.position) }
    nextSymbol()
    let expression = try parseExpression()
    return AstRecordRow(position: identifier.position + expression.position,
                        label: identifier,
                        expression: expression)
  }
  
  func parseRecordSelectorExpression() throws -> AstRecordSelectorExpression {
    guard expecting("#") else { throw reportError("expecting `#`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    let label = try parseIdentifierPattern()
    let record = try parseExpression()
    return AstRecordSelectorExpression(position: startingPosition + label.position,
                                       label: label,
                                       record: record)
  }
  
  func parseListExpression() throws -> AstListExpression {
    guard expecting(.leftBracket) else { throw reportError("expecting `[`", symbol.position) }
    let startingPosition = symbol.position
    nextSymbol()
    if expecting(.rightBracket) {
      let endPosition = symbol.position
      nextSymbol()
      return AstListExpression(position: startingPosition + endPosition,
                               elements: [])
    }
    let expressions = try parseCommaSeparatedExpressions()
    guard expecting(.rightBracket) else { throw reportError("expecting `]`", symbol.position) }
    nextSymbol()
    let endingPosition = symbol.position
    return AstListExpression(position: startingPosition + endingPosition,
                             elements: expressions)
  }
}

private extension SynAn {
  @discardableResult
  func nextSymbol() -> Symbol {
    symbol = lexan.nextSymbol()
    return symbol
  }
  
  func reportError(_ error: String, _ position: Position, _ others: CustomStringConvertible...) -> Error {
    let errorMessage = error + " " + others
      .map { "`\($0.description)`" }
      .joined(separator: " ")
    return Error.syntaxError("Syntax error \(position.description): " + errorMessage)
  }
  
  func expecting(_ type: TokenType) -> Bool {
    return symbol.token == type
  }
  
  func expecting(_ lexeme: String) -> Bool {
    return symbol.lexeme == lexeme
  }
}
