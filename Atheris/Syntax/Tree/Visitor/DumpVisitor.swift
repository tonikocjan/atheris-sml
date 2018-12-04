//
//  DumpVisitor.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class DumpVisitor {
  let outputStream: OutputStream
  let symbolDescription: SymbolDescriptionProtocol?
  
  convenience init(outputStream: OutputStream) {
    self.init(outputStream: outputStream, symbolDescription: nil)
  }
  
  init(outputStream: OutputStream, symbolDescription: SymbolDescriptionProtocol?) {
    self.outputStream = outputStream
    self.symbolDescription = symbolDescription
  }
  
  private var indent = 0
  private let indentIncrement = 2
}

extension DumpVisitor: AstVisitor {
  func visit(node: AstBindings) throws {
    print("AstBindings", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    for binding in node.bindings { try binding.accept(visitor: self) }
    decreaseIndent()
  }
  
  func visit(node: AstValBinding) throws {
    print("AstValBinding", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    try node.pattern.accept(visitor: self)
    try node.expression.accept(visitor: self)
    decreaseIndent()
  }
  
  func visit(node: AstFunBinding) throws {
    print("AstFunBinding", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    print("todo")
    decreaseIndent()
  }
  
  func visit(node: AstAtomType) throws {
    print("AstAtomType", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    print("Name: " + node.name)
    print("Atom type: " + node.type.rawValue)
    decreaseIndent()
  }
  
  func visit(node: AstTypeName) throws {
    print("AstTypeName", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    print("Name: " + node.name)
    decreaseIndent()
  }
  
  func visit(node: AstTupleType) throws {
    print("AstTupleType", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    for type in node.types { try type.accept(visitor: self) }
    decreaseIndent()
  }
  
  func visit(node: AstConstantExpression) throws {
    print("AstConstantExpression", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    print("Value: " + node.value)
    print("Atom type: " + node.type.rawValue)
    decreaseIndent()
  }
  
  func visit(node: AstNameExpression) throws {
    print("AstNameExpression", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    print("Name: " + node.name)
    decreaseIndent()
  }
  
  func visit(node: AstTupleExpression) throws {
    print("AstTupleExpression", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    for expression in node.expressions { try expression.accept(visitor: self) }
    decreaseIndent()
  }
  
  func visit(node: AstBinaryExpression) throws {
    print("AstBinaryExpression `\(node.operation.rawValue)`", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    try node.left.accept(visitor: self)
    try node.right.accept(visitor: self)
    decreaseIndent()
  }
  
  func visit(node: AstUnaryExpression) throws {
    print("AstUnaryExpression `\(node.operation.rawValue)`", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    try node.expression.accept(visitor: self)
    decreaseIndent()
  }
  
  func visit(node: AstIfExpression) throws {
    print("AstIfExpression", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    try node.condition.accept(visitor: self)
    try node.trueBranch.accept(visitor: self)
    try node.falseBranch.accept(visitor: self)
    decreaseIndent()
  }
  
  func visit(node: AstIdentifierPattern) throws {
    print("AstIdentifierPattern", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    print("Name: " + node.name)
    decreaseIndent()
  }
  
  func visit(node: AstWildcardPattern) throws {
    print("AstWildcardPattern", node.position)
    printSemanticInformation(node: node)
  }
  
  func visit(node: AstTuplePattern) throws {
    print("AstTuplePattern", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    for pattern in node.patterns { try pattern.accept(visitor: self) }
    decreaseIndent()
  }
  
  func visit(node: AstRecordPattern) throws {
    print("AstRecordPattern", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    decreaseIndent()
  }
  
  func visit(node: AstTypedPattern) throws {
    print("AstTypedPattern", node.position)
    increaseIndent()
    printSemanticInformation(node: node)
    try node.pattern.accept(visitor: self)
    try node.type.accept(visitor: self)
    decreaseIndent()
  }
}

private extension DumpVisitor {
  func print(_ string: String, _ position: Position) {
    outputStream.print("\(withIndent(string)) \(position.description):")
  }
  
  func print(_ string: String) {
    outputStream.print(withIndent(string))
  }
  
  func withIndent(_ string: String) -> String {
    return (0..<indent).map { _ in " " }.joined() + string
  }
  
  func increaseIndent() { indent += indentIncrement }
  func decreaseIndent() { indent -= indentIncrement }
  
  func printSemanticInformation(node: AstNode) {
    guard let symbolDescription = symbolDescription else { return }
    
    if let binding = symbolDescription.binding(for: node) {
      print("-> defined at: ", binding.position)
    }
    
    if let type = symbolDescription.type(for: node) {
      print("-> typed: " + type.description)
    }
  }
}
