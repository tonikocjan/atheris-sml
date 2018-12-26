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
  private var dontPrintParents = false
  private var debugPrintBindingName = true
  private var expandingDatatypeCaseType = false
  private var expandingDatatypeCaseCounter = 0
  private var printList = false
  private var rhs = false
  
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
        dontPrintParents = true
        try binding.pattern.accept(visitor: self)
        dontPrintParents = false
      }
      newLine()
    }
  }
  
  func visit(node: AstValBinding) throws {
    print("(define ")
    try node.pattern.accept(visitor: self)
    print(" ")
    rhs = true
    try node.expression.accept(visitor: self)
    rhs = false
    print(")")
  }
  
  func visit(node: AstFunBinding) throws {
    func handleOneCase() throws {
      print("(define (\(node.identifier.name) ")
      dontPrintParents = true
      try node.cases.first!.parameter.accept(visitor: self)
      dontPrintParents = false
      print(")")
      increaseIndent()
      newLine()
      try node.cases.first!.body.accept(visitor: self)
      print(")")
      decreaseIndent()
    }
    
    func handleMoreCases() throws {
      let varName = "x"
      print("(define (\(node.identifier.name) \(varName))")
      increaseIndent()
      newLine()
      print("(cond")
      increaseIndent()
      newLine()
      for (idx, case_) in node.cases.enumerated() {
        guard let pattern = self.symbolDescription.type(for: case_.parameter) else { return }
        print("[(")
        if let datatype = pattern as? DatatypeType {
          print("\(datatype.name)?")
          self.print(" x) ")
        } else {
          self.print("equal? ")
          if pattern.isTuple {
            printList = true
          }
          try case_.parameter.accept(visitor: self)
          printList = false
          self.print(" x) ")
        }
        try case_.body.accept(visitor: self)
        self.print("]")
        if idx <= node.cases.count {
          newLine()
        }
      }
      decreaseIndent()
      decreaseIndent()
      print("))")
    }
      
    if node.cases.count == 1 { try handleOneCase() }
    else { try handleMoreCases() }
  }
  
  func visit(node: AstAnonymousFunctionBinding) throws {
    for case_ in node.cases {
      print("(lambda (")
      try case_.parameter.accept(visitor: self)
      print(")")
      increaseIndent()
      newLine()
      try case_.body.accept(visitor: self)
      print(")")
      decreaseIndent()
    }
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
    print(" #:transparent)")
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
    guard let type = symbolDescription.type(for: node) else { return }
    if rhs && !printList, type is DatatypeType || (type as? FunctionType)?.body is DatatypeType, let binding = symbolDescription.binding(for: node) as? AstCase, binding.associatedType == nil {
      print("(\(node.name) 0)")
    } else {
      print(node.name)
    }
  }
  
  func visit(node: AstTupleExpression) throws {
    if printList { print("(list ") }
    try perform(on: node.expressions, appending: " ")
    if printList { print(")") }
  }
  
  func visit(node: AstBinaryExpression) throws {
//    guard
//      let nodeType = symbolDescription.type(for: node),
//      let lhsType = symbolDescription.type(for: node.left),
//      let rhsType = symbolDescription.type(for: node.right) else { return }
    
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
      operation = "cons"
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
    let binding = symbolDescription.binding(for: node) as? AstFunBinding
    print("(")
    print(functionName(for: node.name))
    print(" ")
    dontPrintParents = true
    if let binding = binding, binding.cases.count > 1 {
      if let parameter = symbolDescription.type(for: binding.cases.first!.parameter), parameter.isTuple {
        printList = true
      }
      try node.argument.accept(visitor: self)
      printList = false
    } else {
      try node.argument.accept(visitor: self)
    }
    dontPrintParents = false
    print(")")
  }
  
  func visit(node: AstAnonymousFunctionCall) throws {
    print("(")
    try node.function.accept(visitor: self)
    print(" ")
    dontPrintParents = true
    try node.argument.accept(visitor: self)
    dontPrintParents = false
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
    let rhs_ = rhs
    rhs = false
    try perform(on: rules, appending: "") {
      guard let pattern = self.symbolDescription.type(for: $0.pattern) else { return }
      self.print("[")
      let shouldPrintPattern: Bool
      if let datatype = pattern as? DatatypeType {
        self.print("(\(datatype.name)? ")
        shouldPrintPattern = false
        try node.expression.accept(visitor: self)
      } else {
        self.print("(equal? ")
        shouldPrintPattern = true
        self.printList = true
        try node.expression.accept(visitor: self)
        self.printList = false
        self.print(" ")
      }
      if shouldPrintPattern {
        if pattern.isTuple {
          self.printList = true
        }
        try $0.pattern.accept(visitor: self)
        self.printList = false
      }
      self.print(")")
      self.print(" ")
      if let associatedType = $0.associatedValue {
        self.print("(let ([")
        try associatedType.accept(visitor: self)
        self.print(" ")
        if let identifierPattern = $0.pattern as? AstIdentifierPattern, pattern is DatatypeType {
          self.print("(\(identifierPattern.name)-x0 ")
          try node.expression.accept(visitor: self)
          self.print(")")
        } else {
          try node.expression.accept(visitor: self)
        }
        self.print("]) ")
        try $0.expression.accept(visitor: self)
        self.print(")")
      } else {
        try $0.expression.accept(visitor: self)
      }
      self.print("]")
      self.newLine()
    }
    rhs = rhs_
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
    if !dontPrintParents {
      print("(")
      if printList { print("list ") }
    }
    try perform(on: node.patterns, appending: " ")
    if !dontPrintParents { print(")") }
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
      .reduce("", { result, _ in result + " " })
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
