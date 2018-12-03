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
  }
  
  func visit(node: AstFunBinding) throws {
    self.binding = node
  }
  
  func visit(node: AstAtomType) throws {
    
  }
  
  func visit(node: AstTypeName) throws {
    
  }
  
  func visit(node: AstConstantExpression) throws {
    
  }
  
  func visit(node: AstIdentifierPattern) throws {
    try insertIdentifier(identifier: node)
  }
  
  func visit(node: AstWildcardPattern) throws {
    
  }
  
  func visit(node: AstTuplePattern) throws {
    
  }
  
  func visit(node: AstRecordPattern) throws {
    
  }
  
  func visit(node: AstTypedPattern) throws {
    
  }
}

private extension NameChecker {
  func insertIdentifier(identifier: AstIdentifierPattern) throws {
    guard let binding = binding else { return }
    try symbolTable.addBindingToCurrentScope(name: identifier.name, binding: binding)
  }
}
