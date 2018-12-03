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
        throw Error.typeError(patternType: patternType, expressionType: expressionType)
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
    guard let binding = symbolTable.findBinding(name: node.name) else { throw Error.internalError }
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
    try node.left.accept(visitor: self)
    try node.right.accept(visitor: self)
  }
  
  func visit(node: AstUnaryExpression) throws {
    try node.expression.accept(visitor: self)
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
      throw Error.constraintError(patternType: patternType, constraintType: type)
    }
    
    symbolDescription.setType(for: node, type: type)
  }
}

extension TypeChecker  {
  enum Error: AtherisError {
    case internalError
    case typeError(patternType: Type, expressionType: Type)
    case constraintError(patternType: Type, constraintType: Type)
    
    var errorMessage: String {
      switch self {
      case .internalError: return "internal error: \(Thread.callStackSymbols.joined(separator: "\n"))"
      case .typeError(let patternType, let expressionType): return "error: pattern and expression type do not match\n    pattern: \(patternType.description)\n    expression: \(expressionType.description)"
      case .constraintError(let patternType, let constraintType): return "error: pattern and contraint do not match\n    pattern: \(patternType.description)\n    constraint: \(constraintType.description)"
      }
    }
  }
}

private extension TypeChecker {
  
}
