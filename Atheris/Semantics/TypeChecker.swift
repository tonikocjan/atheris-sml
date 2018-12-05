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
  private static let dummyTypeCharacterSet = Array("ABCDEFGHIJKLMNOPRSTVUZ".reversed())
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
    let operation = Operation.convert(node.operation)
    try node.left.accept(visitor: self)
    try node.right.accept(visitor: self)
    
    guard
      let leftType = symbolDescription.type(for: node.left),
      let rightType = symbolDescription.type(for: node.right) else { throw Error.internalError }
    
    guard let resultType = leftType.isBinaryOperationValid(operation, other: rightType) else {
      throw Error.operatorError(position: node.position, domain: operation.domain, operand: TupleType.formPair(leftType, rightType))
    }
    
    symbolDescription.setType(for: node, type: resultType)
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
  
  func visit(node: AstIdentifierPattern) throws {
    if let parentNodeType = typeDistributionStack.last {
      symbolDescription.setType(for: node, type: parentNodeType)
      return
    }
    
    let dummyPatternType = PatternDummyType(name: "'\(TypeChecker.dummyTypeCharacterSet[dummyTypeCount])") // TODO: -
    symbolDescription.setType(for: node, type: dummyPatternType)
    dummyTypeCount += 1
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
