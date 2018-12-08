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
  private var shouldPrintParents = false
  private var debugPrintBindingName = true
  
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
    let printWelcome: Bool
    
    static let standard = Configuration(indentation: 2, pretty: true, printWelcome: true)
  }
}

// MARK: - CodeGenerator
extension RacketCodeGenerator: CodeGenerator {
  func visit(node: AstBindings) throws {
    if isRootNode {
      if configuration.printWelcome {
        print("; Generated by SML -> Racket 🚀 compiler (`https://gitlab.com/seckmaster/atheris-swift/tree/sml)`\n")
        newLine()
      }
      print("#lang racket\n")
      newLine()
      isRootNode = false
    }
    
    for binding in node.bindings {
      try binding.accept(visitor: self)
      newLine()
      shouldPrintParents = true
      try binding.pattern.accept(visitor: self)
      shouldPrintParents = false
      newLine()
    }
  }
  
  func visit(node: AstValBinding) throws {
    print("(define ")
    try node.pattern.accept(visitor: self)
    print(" ")
    try node.expression.accept(visitor: self)
    print(")")
  }
  
  func visit(node: AstFunBinding) throws {
    print("(define (\(node.identifier.name) ")
    shouldPrintParents = true
    try node.parameter.accept(visitor: self)
    shouldPrintParents = false
    print(")")
    increaseIndent()
    newLine()
    try node.body.accept(visitor: self)
    print(")")
    decreaseIndent()
  }
  
  func visit(node: AstAnonymousFunctionBinding) throws {
    print("(lambda (")
    try node.parameter.accept(visitor: self)
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
    if !shouldPrintParents { print("(list ") }
    try perform(on: node.expressions, appending: " ")
    if !shouldPrintParents { print(")") }
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
    shouldPrintParents = true
    try node.argument.accept(visitor: self)
    shouldPrintParents = false
    print(")")
  }
  
  func visit(node: AstAnonymousFunctionCall) throws {
    print("(")
    try node.function.accept(visitor: self)
    print(" ")
    shouldPrintParents = true
    try node.argument.accept(visitor: self)
    shouldPrintParents = false
    print(")")
  }
  
  func visit(node: AstRecordExpression) throws {
    print("(list ")
    try perform(on: node.rows, appending: " ")
    print(")")
  }
  
  func visit(node: AstRecordRow) throws {
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstRecordSelectorExpression) throws {
    guard
      let record = symbolDescription.type(for: node.record)?.toRecord,
      let rowIndex = record.index(of: node.label.name) else { return }
    
    increaseIndent()
    newLine()
    print("(car ")
    for _ in 0..<rowIndex {
      increaseIndent()
      newLine()
      print("(cdr ")
    }
    try node.record.accept(visitor: self)
    print(")")
    decreaseIndent()
    for _ in 0..<rowIndex {
      print(")")
      decreaseIndent()
    }
  }
  
  func visit(node: AstListExpression) throws {
    print("(list ")
    try perform(on: node.elements, appending: " ")
    print(")")
  }
  
  func visit(node: AstIdentifierPattern) throws {
    print(node.name)
  }
  
  func visit(node: AstWildcardPattern) throws {
    
  }
  
  func visit(node: AstTuplePattern) throws {
    if !shouldPrintParents { print("(") }
    try perform(on: node.patterns, appending: " ")
    if !shouldPrintParents { print(")") }
  }
  
  func visit(node: AstRecordPattern) throws {
    
  }
  
  func visit(node: AstTypedPattern) throws {
    try node.pattern.accept(visitor: self)
  }
  
  func visit(node: AstMatch) throws {
    
  }
  
  func visit(node: AstRule) throws {
    
  }
}

private extension RacketCodeGenerator {
  func print(_ string: String) {
    outputStream.print(string)
  }
  
  func indentation() -> String {
    return (0..<indent)
      .map { _ in " " }
      .joined()
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
