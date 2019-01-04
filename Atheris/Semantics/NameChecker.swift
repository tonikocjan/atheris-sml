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
  
  private var checkingCaseExpression = false
  
  init(symbolTable: SymbolTableProtocol, symbolDescription: SymbolDescriptionProtocol) {
    self.symbolTable = symbolTable
    self.symbolDescription = symbolDescription
    
    insertBuiltinFunctions()
  }
  
  private func insertBuiltinFunctions() {
    let hd = AstFunBinding(position: .zero,
                           identifier: AstIdentifierPattern(position: .zero, name: "hd"),
                           parameter: AstIdentifierPattern(position: .zero, name: "lst"),
                           body: AstConstantExpression(position: .zero, value: "", type: .int))
    let tl = AstFunBinding(position: .zero,
                           identifier: AstIdentifierPattern(position: .zero, name: "tl"),
                           parameter: AstIdentifierPattern(position: .zero, name: "lst"),
                           body: AstConstantExpression(position: .zero, value: "", type: .int))
    let null = AstFunBinding(position: .zero,
                             identifier: AstIdentifierPattern(position: .zero, name: "null"),
                             parameter: AstIdentifierPattern(position: .zero, name: "null"),
                             body: AstConstantExpression(position: .zero, value: "", type: .bool))
    [hd, tl, null].forEach {
      try! symbolTable.addBindingToCurrentScope(name: $0.identifier.name,
                                                binding: $0) }
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
    try insertBinding(node, name: node.identifier.name)
    for case_ in node.cases {
      symbolTable.newScope()
      checkingCaseExpression = node.cases.count > 1
      try case_.parameter.accept(visitor: self)
      checkingCaseExpression = false
      try case_.body.accept(visitor: self)
      symbolTable.oldScope()
    }
  }
  
  func visit(node: AstAnonymousFunctionBinding) throws {
    for case_ in node.cases {
      symbolTable.newScope()
      try case_.parameter.accept(visitor: self)
      try case_.body.accept(visitor: self)
      symbolTable.oldScope()
    }
  }
  
  func visit(node: AstDatatypeBinding) throws {
    try insertBinding(node, name: node.name)
    for case_ in node.cases {
      try insertBinding(case_, name: case_.name)
    }
  }
  
  func visit(node: AstCase) throws {
    try node.name.accept(visitor: self)
    try node.associatedType?.accept(visitor: self)
  }

  func visit(node: AstTypeName) throws {
    if let _ = AstAtomType.AtomType(rawValue: node.name) { return }
    guard let binding = symbolTable.findBinding(name: node.name) else { throw Error.bindingNotFound(node.name, node.position) }
    symbolDescription.bindNode(node, binding: binding)
  }
  
  func visit(node: AstNameExpression) throws {
    switch node.name {
    case "hd", "tl":
      return
    default:
      break
    }
    
    guard let binding = symbolTable.findBinding(name: node.name) else {
      throw Error.bindingNotFound(node.name, node.position)
    }
    symbolDescription.bindNode(node, binding: binding)
  }
  
  func visit(node: AstTupleExpression) throws {
    for expression in node.expressions { try expression.accept(visitor: self) }
  }
  
  func visit(node: AstBinaryExpression) throws {
    try node.left.accept(visitor: self)
    try node.right.accept(visitor: self)
  }
  
  func visit(node: AstUnaryExpression) throws {
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstIfExpression) throws {
    try node.condition.accept(visitor: self)
    try node.trueBranch.accept(visitor: self)
    try node.falseBranch.accept(visitor: self)
  }
  
  func visit(node: AstLetExpression) throws {
    symbolTable.newScope()
    try node.bindings.accept(visitor: self)
    try node.expression.accept(visitor: self)
    symbolTable.oldScope()
  }
  
  func visit(node: AstFunctionCallExpression) throws {
    guard let binding = symbolTable.findBinding(name: node.name) else {
      throw Error.bindingNotFound(node.name, node.position)
    }
    symbolDescription.bindNode(node, binding: binding)
    try node.argument.accept(visitor: self)
  }
  
  func visit(node: AstAnonymousFunctionCall) throws {
    try node.argument.accept(visitor: self)
    try node.function.accept(visitor: self)
  }
  
  func visit(node: AstRecordExpression) throws {
    symbolTable.newScope()
    for row in node.rows { try row.accept(visitor: self) }
    symbolTable.oldScope()
  }
  
  func visit(node: AstRecordSelectorExpression) throws {
    try node.record.accept(visitor: self)
  }
  
  func visit(node: AstRecordRow) throws {
    try node.label.accept(visitor: self)
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstListExpression) throws {
    for element in node.elements { try element.accept(visitor: self) }
  }
  
  func visit(node: AstCaseExpression) throws {
    symbolTable.newScope()
    try node.expression.accept(visitor: self)
    try node.match.accept(visitor: self)
    symbolTable.oldScope()
  }
  
  func visit(node: AstIdentifierPattern) throws {
    if checkingCaseExpression {
      guard let binding = symbolTable.findBinding(name: node.name) else {
        throw Error.bindingNotFound(node.name, node.position)
      }
      symbolDescription.bindNode(node, binding: binding)
    } else {
      try insertBinding(node, name: node.name)
    }
  }
  
  func visit(node: AstTuplePattern) throws {
    for pattern in node.patterns { try pattern.accept(visitor: self) }
  }
  
  func visit(node: AstTypedPattern) throws {
    try node.pattern.accept(visitor: self)
    try node.type.accept(visitor: self)
  }
  
  func visit(node: AstListPattern) throws {
    let checkingCaseExpression_ = checkingCaseExpression
    checkingCaseExpression = false
    try node.head.accept(visitor: self)
    try node.tail.accept(visitor: self)
    checkingCaseExpression = checkingCaseExpression_
  }
  
  func visit(node: AstMatch) throws {
    for rule in node.rules {
      symbolTable.newScope()
      try rule.accept(visitor: self)
      symbolTable.oldScope()
    }
  }
  
  func visit(node: AstRule) throws {
    checkingCaseExpression = true
    try node.pattern.accept(visitor: self)
    checkingCaseExpression = false
    try node.associatedValue?.accept(visitor: self)
    try node.expression.accept(visitor: self)
  }
}

extension NameChecker {
  enum Error: AtherisError {
    case bindingNotFound(String, Position)
    case bindingExists(String, Position)
    
    var errorMessage: String {
      switch self {
      case .bindingNotFound(let name, let position):
        return "error \(position.description): use of undeclared name `\(name)`"
      case .bindingExists(let name, let position):
        return "error \(position.description): `\(name)` already exists"
      }
    }
  }
}

private extension NameChecker {
  func insertBinding(_ binding: AstBinding, name: String) throws {
    do {
      try symbolTable.addBindingToCurrentScope(name: name,
                                               binding: binding)
    } catch {
      throw Error.bindingExists(name, binding.position)
    }
  }
  
  func insertBinding(_ binding: AstBinding, name: AstIdentifierPattern) throws {
    try insertBinding(binding, name: name.name)
  }
}
