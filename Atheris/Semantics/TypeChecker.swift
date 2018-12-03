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
  
  private static let dummyTypeCharacterSet = Array("ABCDEFGHIJKLMNOPRSTVUZ".reversed())
  private var dummyTypeCount = 0
  
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
    
    if let patternType = symbolDescription.type(for: node.pattern) {
      guard patternType.sameStructureAs(other: expressionType) else {
        throw Error.typeError(patternType: patternType, expressionType: expressionType)
      }
      
      symbolDescription.setType(for: node, type: expressionType)
    } else {
      // expression's type is infered to pattern and node
      symbolDescription.setType(for: node.pattern, type: expressionType)
      symbolDescription.setType(for: node, type: expressionType)
    }
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
  
  func visit(node: AstIdentifierPattern) throws {
    let dummyPatternType = PatternDummyType(name: "'\(TypeChecker.dummyTypeCharacterSet[dummyTypeCount])") // TODO: -
    symbolDescription.setType(for: node, type: dummyPatternType)
    dummyTypeCount += 1
  }
  
  func visit(node: AstWildcardPattern) throws {
    
  }
  
  func visit(node: AstTuplePattern) throws {
    for pattern in node.patterns { try pattern.accept(visitor: self) }
    let types = node.patterns.compactMap { symbolDescription.type(for: $0) as? PatternType }
    let tuplePatternType = PatternTupleType(members: types)
    symbolDescription.setType(for: node, type: tuplePatternType)
  }
  
  func visit(node: AstRecordPattern) throws {
    
  }
  
  func visit(node: AstTypedPattern) throws {
    try node.type.accept(visitor: self)
    try node.pattern.accept(visitor: self)
    
    guard
      let type = symbolDescription.type(for: node.type),
      let patternType = symbolDescription.type(for: node.pattern) else {
        throw Error.internalError
    }
    
    guard type.sameStructureAs(other: patternType) else {
      throw Error.constraintError(patternType: patternType, constraintType: type)
    }
  }
}

extension TypeChecker {
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
