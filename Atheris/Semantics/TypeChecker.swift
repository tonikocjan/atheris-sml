//
//  TypeChecker.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class TypeChecker {
  let symbolTable: SymbolTableProtocol
  let symbolDescription: SymbolDescriptionProtocol
  
  // MARK: - dummy types
  private static let dummyTypeCharacterSet = Array("ABCDEFGHIJKLMNOPRSTVUZA1B1C1D1E1F1G1H1I1J1K1L1M1N1O1P1R1S1T1V1U1Z1".reversed())
  private var dummyTypeCount = 0
  
  // MARK: - Type distribution stack
  private var typeDistributionStack = [Type]()
  
  init(symbolTable: SymbolTableProtocol, symbolDescription: SymbolDescriptionProtocol) {
    self.symbolTable = symbolTable
    self.symbolDescription = symbolDescription
  }
}

extension TypeChecker: AstVisitor {
  func visit(node: AstBindings) throws {
    for binding in node.bindings { try binding.accept(visitor: self) }
  }
  
  func visit(node: AstValBinding) throws {
    try node.expression.accept(visitor: self)
    try node.pattern.accept(visitor: self)
    
    guard let expressionType = symbolDescription.type(for: node.expression) else {
      throw Error.internalError
    }
    
    let resultType: Type
    
    if let patternType = symbolDescription.type(for: node.pattern) {
      guard patternType.sameStructureAs(other: expressionType) else {
        throw Error.typeError(position: node.position, patternType: patternType, expressionType: expressionType)
      }
      symbolDescription.setType(for: node, type: expressionType)
      resultType = expressionType
    } else {
      // expression's type is assigned to pattern and node
      symbolDescription.setType(for: node.pattern, type: expressionType)
      symbolDescription.setType(for: node, type: expressionType)
      resultType = expressionType
    }
    
    // distribute top-level type to child nodes
    typeDistributionStack.append(resultType)
    try node.pattern.accept(visitor: self)
    _ = typeDistributionStack.popLast()
  }
  
  func visit(node: AstFunBinding) throws {
    try node.identifier.accept(visitor: self)
    for parameter in node.parameters { try parameter.accept(visitor: self) }
    try node.body.accept(visitor: self)
    for parameter in node.parameters { try parameter.accept(visitor: self) }
    let parameterTypes = node.parameters.compactMap { symbolDescription.type(for: $0) as? TupleType }
    guard let bodyType = symbolDescription.type(for: node.body) else { throw Error.internalError }
    let functionType = FunctionType(name: node.identifier.name,
                                    parameters: parameterTypes,
                                    body: bodyType)
    symbolDescription.setType(for: node, type: functionType)
    symbolDescription.setType(for: node.identifier, type: functionType)
  }
  
  func visit(node: AstAtomType) throws {
    let atomType = AtomType(type: node.type)
    symbolDescription.setType(for: node, type: atomType)
  }
  
  func visit(node: AstTypeName) throws {
    func builtinType(name: String) -> AtomType? {
      return ["int": AtomType(type: .int),
              "string": AtomType(type: .string),
              "bool": AtomType(type: .bool),
              "real": AtomType(type: .real)][name]
    }
    
    if let atomType = builtinType(name: node.name) {
      symbolDescription.setType(for: node, type: atomType)
    } else {
      guard let binding = symbolTable.findBinding(name: node.name) else { throw Error.internalError }
      guard let type = symbolDescription.type(for: binding) else { throw Error.internalError }
      symbolDescription.setType(for: node, type: type)
    }
  }
  
  func visit(node: AstTupleType) throws {
    for type in node.types { try type.accept(visitor: self) }
    let types = node.types.compactMap { symbolDescription.type(for: $0) }
    let tupleType = TupleType(members: types)
    symbolDescription.setType(for: node, type: tupleType)
  }
  
  func visit(node: AstConstantExpression) throws {
    let atomType = AtomType(type: node.type)
    symbolDescription.setType(for: node, type: atomType)
  }
  
  func visit(node: AstNameExpression) throws {
    guard let binding = symbolDescription.binding(for: node) else { throw Error.internalError }
    guard let type = symbolDescription.type(for: binding) else { throw Error.internalError }
    symbolDescription.setType(for: node, type: type)
  }
  
  func visit(node: AstTupleExpression) throws {
    for expression in node.expressions { try expression.accept(visitor: self) }
    let types = node.expressions.compactMap { symbolDescription.type(for: $0) }
    let tupleType = TupleType(members: types)
    symbolDescription.setType(for: node, type: tupleType)
  }
  
  func visit(node: AstBinaryExpression) throws {
    func applyType(_ resultType: Type, leftType: Type, rightType: Type) {
      symbolDescription.setType(for: node, type: resultType)
      
      if leftType.isAbstract, let leftBinding = symbolDescription.binding(for: node.left) {
        symbolDescription.setType(for: node.left, type: resultType)
        symbolDescription.setType(for: leftBinding, type: resultType)
      }
      
      if rightType.isAbstract, let rightBinding = symbolDescription.binding(for: node.right) {
        symbolDescription.setType(for: rightBinding, type: resultType)
        symbolDescription.setType(for: node.right, type: resultType)
      }
    }
    
    let operation = Operation.convert(node.operation)
    try node.left.accept(visitor: self)
    try node.right.accept(visitor: self)
    
    guard
      let leftType = symbolDescription.type(for: node.left),
      let rightType = symbolDescription.type(for: node.right) else { throw Error.internalError }
    
    guard leftType.isConcrete && rightType.isConcrete else {
      let defaultType = Operation.convert(node.operation).defaultType
      applyType(defaultType, leftType: leftType, rightType: rightType)
      return
    }
    
    guard let resultType = leftType.isBinaryOperationValid(operation, other: rightType) else {
      throw Error.operatorError(position: node.position, domain: operation.domain, operand: TupleType.formPair(leftType, rightType))
    }
    
    applyType(resultType, leftType: leftType, rightType: rightType)
  }
  
  func visit(node: AstUnaryExpression) throws {
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstIfExpression) throws {
    try node.condition.accept(visitor: self)
    try node.trueBranch.accept(visitor: self)
    try node.falseBranch.accept(visitor: self)
    
    guard
      let conditionType = symbolDescription.type(for: node.condition),
      let trueBranchType = symbolDescription.type(for: node.trueBranch),
      let falseBranchType = symbolDescription.type(for: node.falseBranch) else { throw Error.internalError }
    
    guard conditionType.isBool else {
      throw Error.testExpressionError(position: node.condition.position, testExpressionType: conditionType)
    }
    
    guard trueBranchType.sameStructureAs(other: falseBranchType) else {
      throw Error.branchesTypeMistmatchError(position: node.position, trueBranchType: trueBranchType, falseBranchType: falseBranchType)
    }
    
    symbolDescription.setType(for: node, type: trueBranchType)
  }
  
  func visit(node: AstLetExpression) throws {
    try node.bindings.accept(visitor: self)
    try node.expression.accept(visitor: self)
    guard let expressionType = symbolDescription.type(for: node.expression) else { throw Error.internalError }
    symbolDescription.setType(for: node, type: expressionType)
  }
  
  func visit(node: AstFunctionCallExpression) throws {
    func areArgumentsAndParametersOfSameStructure(arguments: [TupleType], parameters: [TupleType]) -> Bool {
      guard arguments.count == parameters.count else { return false }
      return zip(arguments, parameters)
        .reduce(true, { (acc, tuple) in acc && tuple.0.sameStructureAs(other: tuple.1) })
    }
    
    guard
      let binding = symbolDescription.binding(for: node),
      let functionType = symbolDescription.type(for: binding)?.asFunction else { throw Error.internalError }
    
    for argument in node.arguments { try argument.accept(visitor: self) }
    let argumentTypes = node.arguments.compactMap { symbolDescription.type(for: $0) as? TupleType }
    guard areArgumentsAndParametersOfSameStructure(arguments: argumentTypes, parameters: functionType.parameters) else {
      throw Error.operatorError(position: node.position,
                                domain: functionType.parameters.description,
                                operand: TupleType(members: argumentTypes))
    }
    
    symbolDescription.setType(for: node, type: functionType.body)
  }
  
  func visit(node: AstIdentifierPattern) throws {
    if let parentNodeType = typeDistributionStack.last {
      symbolDescription.setType(for: node, type: parentNodeType)
      return
    }
    
    let dummyPatternType = PatternDummyType(name: dummyName()) // TODO: -
    symbolDescription.setType(for: node, type: dummyPatternType)
  }
  
  func visit(node: AstWildcardPattern) throws {
    
  }
  
  func visit(node: AstTuplePattern) throws {
    if let parentNodeType = typeDistributionStack.last as? TupleType {
      symbolDescription.setType(for: node, type: parentNodeType)
      for (type, pattern) in zip(parentNodeType.members, node.patterns) {
        typeDistributionStack.append(type)
        try pattern.accept(visitor: self)
        _ = typeDistributionStack.popLast()
      }
      return
    }
    let alreadyCalculatedTypes = node.patterns.compactMap { symbolDescription.type(for: $0) }
    guard alreadyCalculatedTypes.count != node.patterns.count else {
      symbolDescription.setType(for: node, type: TupleType(members: alreadyCalculatedTypes))
      return
    }
    
    for pattern in node.patterns { try pattern.accept(visitor: self) }
    let types = node.patterns.compactMap { symbolDescription.type(for: $0) as? PatternType }
    let tuplePatternType = PatternTupleType(members: types)
    symbolDescription.setType(for: node, type: tuplePatternType)
  }
  
  func visit(node: AstRecordPattern) throws {
    
  }
  
  func visit(node: AstTypedPattern) throws {
    if let parentNodeType = typeDistributionStack.last {
      symbolDescription.setType(for: node, type: parentNodeType)
      try node.pattern.accept(visitor: self)
      return
    }
    
    try node.type.accept(visitor: self)
    try node.pattern.accept(visitor: self)
    
    guard
      let type = symbolDescription.type(for: node.type),
      let patternType = symbolDescription.type(for: node.pattern) else {
        throw Error.internalError
    }
    
    guard patternType.sameStructureAs(other: type) else {
      throw Error.constraintError(position: node.position, patternType: patternType, constraintType: type)
    }
    
    symbolDescription.setType(for: node, type: type)
    symbolDescription.setType(for: node.pattern, type: type)
  }
  
  func dummyName() -> String {
    let name = "'\(TypeChecker.dummyTypeCharacterSet[dummyTypeCount])"
    return name
  }
}

extension TypeChecker  {
  enum Error: AtherisError {
    case internalError
    case typeError(position: Position, patternType: Type, expressionType: Type)
    case constraintError(position: Position, patternType: Type, constraintType: Type)
    case operatorError(position: Position, domain: String, operand: TupleType)
    case testExpressionError(position: Position, testExpressionType: Type)
    case branchesTypeMistmatchError(position: Position, trueBranchType: Type, falseBranchType: Type)
    
    var errorMessage: String {
      switch self {
      case .internalError: return "internal error: \(Thread.callStackSymbols.joined(separator: "\n"))"
      case .typeError(let position, let patternType, let expressionType):
        return """
        error \(position.description): pattern and expression type do not match
            pattern: \(patternType.description)
            expression: \(expressionType.description)
        """
      case .constraintError(let position, let patternType, let constraintType):
        return """
        error \(position.description): pattern and contraint do not match
            pattern: \(patternType.description)
            constraint: \(constraintType.description)
        """
      case .operatorError(let position, let domain, let operand):
        return """
        error \(position.description): operator and operand do not match
            operator domain: \(domain)
            operand: \(operand.description)
        """
      case .testExpressionError(let position, let testExpressionType):
        return """
        error \(position.description): test expression in if is not of type bool
            test expression: \(testExpressionType.description)
        """
      case .branchesTypeMistmatchError(let position, let trueBranchType, let falseBranchType):
        return """
        error \(position.description): types of if branches do not agree
            then branch: \(trueBranchType.description)
            else branch: \(falseBranchType.description)
        """
      }
    }
  }
}
