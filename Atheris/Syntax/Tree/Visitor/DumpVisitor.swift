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
  private var indent = 0
  private let indentIncrement = 2
  
  init(outputStream: OutputStream) {
    self.outputStream = outputStream
  }
}

extension DumpVisitor: AstVisitor {
  func visit(node: AstBindings) {
    print("AstBindings", node.position)
    increaseIndent()
    node.bindings.forEach { $0.accept(visitor: self) }
    decreaseIndent()
  }
  
  func visit(node: AstValBinding) {
    print("AstValBinding", node.position)
    increaseIndent()
    node.pattern.accept(visitor: self)
    node.expression.accept(visitor: self)
    decreaseIndent()
  }
  
  func visit(node: AstFunBinding) {
    print("AstFunBinding", node.position)
    increaseIndent()
    print("todo")
    decreaseIndent()
  }
  
  func visit(node: AstAtomType) {
    print("AstAtomType", node.position)
    increaseIndent()
    print("Identifier: " + node.identifier)
    print("Atom type: " + node.type.rawValue)
    decreaseIndent()
  }
  
  func visit(node: AstTypeName) {
    print("AstTypeName", node.position)
    increaseIndent()
    print("Identifier: " + node.identifier)
    decreaseIndent()
  }
  
  func visit(node: AstConstantExpression) {
    print("AstConstantExpression", node.position)
    increaseIndent()
    print("Value: " + node.value)
    print("Atom type: " + node.type.rawValue)
    decreaseIndent()
  }
  
  func visit(node: AstIdentifierPattern) {
    print("AstIdentifierPattern", node.position)
    increaseIndent()
    print("Name: " + node.name)
    decreaseIndent()
  }
  
  func visit(node: AstWildcardPattern) {
    print("AstWildcardPattern", node.position)
  }
  
  func visit(node: AstTuplePattern) {
    print("AstTuplePattern", node.position)
    increaseIndent()
    node.patterns.forEach { $0.accept(visitor: self) }
    decreaseIndent()
  }
  
  func visit(node: AstRecordPattern) {
    print("AstRecordPattern", node.position)
    increaseIndent()
    decreaseIndent()
  }
  
  func visit(node: AstTypedPattern) {
    print("AstTypedPattern", node.position)
    increaseIndent()
    node.pattern.accept(visitor: self)
    node.type.accept(visitor: self)
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
}
