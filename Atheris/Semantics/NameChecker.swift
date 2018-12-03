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
  
  private var binding: AstBinding?
  
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
    self.binding = node
    try node.pattern.accept(visitor: self)
    try node.expression.accept(visitor: self)
    self.binding = nil
  }
  
  func visit(node: AstFunBinding) throws {
    self.binding = node
    self.binding = nil
  }
  
  func visit(node: AstAtomType) throws {
    
  }
  
  func visit(node: AstTypeName) throws {
    
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
    guard let binding = binding else { return }
    try symbolTable.addBindingToCurrentScope(name: identifier.name, binding: binding)
  }
  
  func findBinding(for name: String) -> AstBinding? {
    return symbolTable.findBinding(name: name)
  }
}
