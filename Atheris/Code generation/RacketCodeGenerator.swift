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
  private var expandingDatatypeCaseType = false
  private var expandingDatatypeCaseCounter = 0
  
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
        print("; Generated by SML -> Racket 🚀 compiler (`https://gitlab.com/seckmaster/atheris-swift/tree/sml`)\n")
        newLine()
      }
      print("#lang racket\n")
      newLine()
      isRootNode = false
    }
    
    for binding in node.bindings {
      try binding.accept(visitor: self)
      newLine()
      if !(binding is AstDatatypeBinding) {
        shouldPrintParents = true
        try binding.pattern.accept(visitor: self)
        shouldPrintParents = false
      }
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
  
  func visit(node: AstDatatypeBinding) throws {
    expandingDatatypeCaseType = true
    try perform(on: node.cases, appending: "") {
      self.newLine()
      self.expandingDatatypeCaseCounter = 0
    }
    expandingDatatypeCaseType = false
  }
  
  func visit(node: AstCase) throws {
    print("(struct ")
    try node.name.accept(visitor: self)
    if let associatedType = node.associatedType {
      print(" (")
      try associatedType.accept(visitor: self)
      print(")")
    } else {
      print(" (_)")
    }
    print(")")
  }
  
  func visit(node: AstAtomType) throws {
    guard expandingDatatypeCaseType else { return }
    print("x\(expandingDatatypeCaseCounter)")
    expandingDatatypeCaseCounter += 1
  }
  
  func visit(node: AstTypeName) throws {
    guard expandingDatatypeCaseType else { return }
    print("x\(expandingDatatypeCaseCounter)")
    expandingDatatypeCaseCounter += 1
  }
  
  func visit(node: AstTupleType) throws {
    guard expandingDatatypeCaseType else { return }
    try perform(on: node.types, appending: " ")
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
    guard
      let nodeType = symbolDescription.type(for: node),
      let lhsType = symbolDescription.type(for: node.left),
      let rhsType = symbolDescription.type(for: node.right) else { return }
    
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
    case .append:
      operation = "append"
    }
    print("(\(operation) ")
    if nodeType.isList {
      guard !lhsType.isList else { return try node.left.accept(visitor: self) }
      print("(list ")
      try node.left.accept(visitor: self)
      print(")")
    } else {
      try node.left.accept(visitor: self)
    }
    print(" ")
    try node.right.accept(visitor: self)
    print(")")
  }
  
  func visit(node: AstUnaryExpression) throws {
    
  }
  
  func visit(node: AstIfExpression) throws {
    print("(if ")
    try node.condition.accept(visitor: self)
    increaseIndent()
    newLine()
    try node.trueBranch.accept(visitor: self)
    newLine()
    try node.falseBranch.accept(visitor: self)
    decreaseIndent()
    print(")")
  }
  
  func visit(node: AstLetExpression) throws {
    try node.bindings.accept(visitor: self)
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstFunctionCallExpression) throws {
    print("(")
    print(functionName(for: node.name))
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
    print("(cons \"")
    try node.label.accept(visitor: self)
    print("\" ")
    try node.expression.accept(visitor: self)
    print(")")
  }
  
  func visit(node: AstRecordSelectorExpression) throws {
    print("(cdr ")
    print("(assoc ")
    print("\"")
    try node.label.accept(visitor: self)
    print("\" ")
    try node.record.accept(visitor: self)
    print("))")
  }
  
  func visit(node: AstListExpression) throws {
    print("(list ")
    try perform(on: node.elements, appending: " ")
    print(")")
  }
  
  func visit(node: AstCaseExpression) throws {
    let rules = node.match.rules
    print("(cond ")
    increaseIndent()
    newLine()
    try perform(on: rules, appending: "") {
      self.print("[")
      self.print("(equal? ")
      try node.expression.accept(visitor: self)
      self.print(" ")
      try $0.pattern.accept(visitor: self)
      self.print(")")
      self.print(" ")
      try $0.expression.accept(visitor: self)
      self.print("]")
      self.newLine()
    }
    decreaseIndent()
    print(")")
  }
  
  func visit(node: AstMatch) throws {
    
  }
  
  func visit(node: AstRule) throws {
    
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
  
  func visit(node: AstConstantPattern) throws {
    print(node.value)
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
  
  func perform<T: AstNode>(on nodes: [T], appending: String, closure: ((T) throws -> Void)?=nil) throws {
    for node in nodes.dropLast() {
      try node.accept(visitor: self)
      print(appending)
      try closure?(node)
    }
    guard let last = nodes.last else { return }
    try last.accept(visitor: self)
    try closure?(last)
  }
  
  func perform(on nodes: [AstNode], appending: String, closure: (() throws -> Void)?=nil) throws {
    for node in nodes.dropLast() {
      try node.accept(visitor: self)
      print(appending)
      try closure?()
    }
    try nodes.last?.accept(visitor: self)
  }
  
  func functionName(for function: String) -> String {
    return RacketCodeGenerator.builtinFunctionsMapping[function] ?? function
  }
  
  static let builtinFunctionsMapping =
    ["hd": "car",
     "tl": "cdr"]
}
