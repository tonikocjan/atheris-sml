//
//  RacketCodeGenerator.swift
//  Atheris
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class RacketCodeGenerator {
  let outputStream: OutputStream
  let configuration: Configuration
  let symbolDescription: SymbolDescriptionProtocol
  
  private var isRootNode = true
  private var indent = 0
  private var debugPrint = false
  
  init(outputStream: OutputStream, configuration: Configuration, symbolDescription: SymbolDescriptionProtocol) {
    self.outputStream = outputStream
    self.configuration = configuration
    self.symbolDescription = symbolDescription
  }
}

extension RacketCodeGenerator {
  struct Configuration {
    let indentation: Int
    let pretty: Bool
    
    static let standard = Configuration(indentation: 2, pretty: true)
  }
}

// MARK: - CodeGenerator
extension RacketCodeGenerator: CodeGenerator {
  func visit(node: AstBindings) throws {
    if isRootNode {
      print("#lang racket\n")
      newLine()
      isRootNode = false
    }
    
    for binding in node.bindings {
      try binding.accept(visitor: self)
      newLine()
      debugPrint = true
      try binding.pattern.accept(visitor: self)
      debugPrint = false
      newLine()
    }
  }
  
  func visit(node: AstValBinding) throws {
    guard let type = symbolDescription.type(for: node) else { return }
    let define = type.isTuple ? "(match-define-values " : "(define "
    print(define)
    try node.pattern.accept(visitor: self)
    print(" ")
    try node.expression.accept(visitor: self)
    print(")")
  }
  
  func visit(node: AstFunBinding) throws {
    print("(define (\(node.identifier.name) ")
    debugPrint = true
    try node.parameters.first?.accept(visitor: self)
    debugPrint = false
    print(")")
    increaseIndent()
    newLine()
    try node.body.accept(visitor: self)
    print(")")
    decreaseIndent()
  }
  
  func visit(node: AstAtomType) throws {
    
  }
  
  func visit(node: AstTypeName) throws {
    
  }
  
  func visit(node: AstTupleType) throws {
    
  }
  
  func visit(node: AstConstantExpression) throws {
    print(node.type == .string ? "\"\(node.value)\"" : node.value)
  }
  
  func visit(node: AstNameExpression) throws {
    print(node.name)
  }
  
  func visit(node: AstTupleExpression) throws {
    if !debugPrint { print("(values ") }
    try perform(on: node.expressions, appending: " ")
    if !debugPrint { print(")") }
  }
  
  func visit(node: AstBinaryExpression) throws {
    let operation: String
    switch node.operation {
    case .add,
         .subtract,
         .multiply,
         .divide,
         .lessThan,
         .greaterThan,
         .lessThanOrEqual,
         .greaterThanOrEqual:
      operation = node.operation.rawValue
    case .andalso:
      operation = "and"
    case .orelse:
      operation = "or"
    case .concat:
      operation = "string-append"
    case .equal:
      operation = "equal?"
    }
    print("(\(operation) ")
    try node.left.accept(visitor: self)
    print(" ")
    try node.right.accept(visitor: self)
    print(")")
  }
  
  func visit(node: AstUnaryExpression) throws {
    
  }
  
  func visit(node: AstIfExpression) throws {
    print("(if ")
    try node.condition.accept(visitor: self)
    print(" ")
    try node.trueBranch.accept(visitor: self)
    print(" ")
    try node.falseBranch.accept(visitor: self)
    print(")")
  }
  
  func visit(node: AstLetExpression) throws {
    try node.bindings.accept(visitor: self)
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstFunctionCallExpression) throws {
    print("(")
    print(node.name)
    print(" ")
    debugPrint = true
    try perform(on: node.arguments, appending: " ")
    debugPrint = false
    print(")")
  }
  
  func visit(node: AstIdentifierPattern) throws {
    print(node.name)
  }
  
  func visit(node: AstWildcardPattern) throws {
    
  }
  
  func visit(node: AstTuplePattern) throws {
    if !debugPrint { print("(") }
    try perform(on: node.patterns, appending: " ")
    if !debugPrint { print(")") }
  }
  
  func visit(node: AstRecordPattern) throws {
    
  }
  
  func visit(node: AstTypedPattern) throws {
    try node.pattern.accept(visitor: self)
  }
}

private extension RacketCodeGenerator {
  func print(_ string: String) {
    outputStream.print(string)
  }
  
  func indentation() -> String {
    return (0..<indent).map { _ in " " }.joined()
  }
  
  func newLine() {
    guard configuration.pretty else { return }
    outputStream.printLine("")
    outputStream.print(indentation())
  }
  
  func increaseIndent() { indent += configuration.indentation }
  func decreaseIndent() { indent -= configuration.indentation }
  
  func perform(on nodes: [AstNode], appending: String) throws {
    for node in nodes.dropLast() {
      try node.accept(visitor: self)
      print(appending)
    }
    try nodes.last?.accept(visitor: self)
  }
}
