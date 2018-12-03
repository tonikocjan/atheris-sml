//
//  NameChecker.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class NameChecker {
  let symbolTable: SymbolTableProtocol
  let symbolDescription: SymbolDescriptionProtocol
  
  init(symbolTable: SymbolTableProtocol, symbolDescription: SymbolDescriptionProtocol) {
    self.symbolTable = symbolTable
    self.symbolDescription = symbolDescription
  }
}

extension NameChecker: AstVisitor {
  func visit(node: AstBindings) throws {
    for binding in node.bindings { try binding.accept(visitor: self) }
  }
  
  func visit(node: AstValBinding) throws {
    try node.pattern.accept(visitor: self)
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstFunBinding) throws {
    
  }
  
  func visit(node: AstAtomType) throws {
    
  }
  
  func visit(node: AstTypeName) throws {
    
  }
  
  func visit(node: AstTupleType) throws {
    
  }
  
  func visit(node: AstConstantExpression) throws {
    
  }
  
  func visit(node: AstNameExpression) throws {
    guard let binding = findBinding(for: node.name) else {
      throw Error.bindingNotFound(node.name, node.position)
    }
    symbolDescription.bindNode(node, binding: binding)
  }
  
  func visit(node: AstTupleExpression) throws {
    for expression in node.expressions { try expression.accept(visitor: self) }
  }
  
  func visit(node: AstIdentifierPattern) throws {
    try insertIdentifier(identifier: node)
  }
  
  func visit(node: AstWildcardPattern) throws {
    
  }
  
  func visit(node: AstTuplePattern) throws {
    for pattern in node.patterns { try pattern.accept(visitor: self) }
  }
  
  func visit(node: AstRecordPattern) throws {
    
  }
  
  func visit(node: AstTypedPattern) throws {
    try node.pattern.accept(visitor: self)
    try node.type.accept(visitor: self)
  }
}

extension NameChecker {
  enum Error: AtherisError {
    case bindingNotFound(String, Position)
    
    var errorMessage: String {
      switch self {
      case .bindingNotFound(let name, let position): return "error \(position.description): use of undeclared name `\(name)`"
      }
    }
  }
}

private extension NameChecker {
  func insertIdentifier(identifier: AstIdentifierPattern) throws {
    try symbolTable.addBindingToCurrentScope(name: identifier.name,
                                             binding: identifier)
  }
  
  func findBinding(for name: String) -> AstBinding? {
    return symbolTable.findBinding(name: name)
  }
}
