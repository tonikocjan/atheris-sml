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
  private var printTuple = true
  private var rhs = false
  private var wildcardPatternCounter = 0
  
  // MARK: - Pattern matching
  private var caseExpressionStack = [AstCaseExpression]()
  private var caseTraversalStateStack = [CaseExpressionTraversalState]()
  
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
      self.dontPrintParents = true
      try case_.parameter.accept(visitor: self)
      self.dontPrintParents = false
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
    
    func isDatatypeConstructorWithoutAssociatedValue() -> Bool {
      guard rhs && !printList else { return false }
      guard type is DatatypeType || (type as? FunctionType)?.body is DatatypeType else { return false }
      if let binding = symbolDescription.binding(for: node) as? AstCase, binding.associatedType == nil {
        return true
      }
      return false
    }
    
    switch caseTraversalState {
    case .rootPattern, .nestedPattern:
      print(node.name)
    case .binding:
      print(node.name)
    case .none:
      if isDatatypeConstructorWithoutAssociatedValue() {
        print("(\(node.name) 0)")
      } else {
        print(node.name)
      }
    }
  }
  
  func visit(node: AstTupleExpression) throws {
    func asList() throws {
      print("(list ")
      try perform(on: node.expressions, appending: " ")
      print(")")
    }
    
    func asTuple() throws {
      for expression in node.expressions.dropLast() {
        print("(cons ")
        try expression.accept(visitor: self)
        print(" ")
      }
      try node.expressions.last?.accept(visitor: self)
      for _ in node.expressions.dropLast() { print(")") }
    }
    
    func onlyValues() throws {
      try perform(on: node.expressions, appending: " ")
    }
    
    let list = printList
    let tuple = printTuple
    
    if list {
      try asList()
    } else if tuple {
      try asTuple()
    } else {
      try onlyValues()
    }
    
    printList = list
    printTuple = tuple
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
    case .modulo:
      operation = "modulo"
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
    switch node.operation {
    case .negate:
      print("(- 0 ")
      try node.expression.accept(visitor: self)
      print(")")
    case .not:
      print("(not ")
      try node.expression.accept(visitor: self)
      print(")")
    }
  }
  
  func visit(node: AstIfExpression) throws {
    print("(if ")
    try node.condition.accept(visitor: self)
    increaseIndent()
    newLine()
    let rhs_ = rhs
    rhs = true
    try node.trueBranch.accept(visitor: self)
    newLine()
    try node.falseBranch.accept(visitor: self)
    rhs = rhs_
    decreaseIndent()
    print(")")
  }
  
  func visit(node: AstLetExpression) throws {
    try node.bindings.accept(visitor: self)
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstFunctionCallExpression) throws {
    printTuple = false
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
    printTuple = true
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
    guard !node.elements.isEmpty else {
      print("null")
      return
    }
    print("(list ")
    try perform(on: node.elements, appending: " ")
    print(")")
  }
  
  func visit(node: AstCaseExpression) throws {
    caseExpressionStack.append(node)
    try node.match.accept(visitor: self)
    _ = caseExpressionStack.popLast()
  }
  
  func visit(node: AstMatch) throws {
    func handlePattern(rule: AstRule) throws {
      caseTraversalStateStack.append(.rootPattern)
      try rule.pattern.accept(visitor: self)
      _ = caseTraversalStateStack.popLast()
    }
    
    func handleBinding(rule: AstRule) throws {
      caseTraversalStateStack.append(.binding)
      print("(let (")
      try rule.pattern.accept(visitor: self)
      print(")")
      _ = caseTraversalStateStack.popLast()
    }
    
    print("(cond ")
    increaseIndent()
    newLine()
    for rule in node.rules {
      print("[")
      try handlePattern(rule: rule)
      print(" ")
      try handleBinding(rule: rule)
      print(" ")
      try rule.expression.accept(visitor: self)
      print(")]")
      newLine()
    }
    print(")")
    decreaseIndent()
  }
  
  func visit(node: AstRule) throws {
    
  }

  func visit(node: AstIdentifierPattern) throws {
    print(node.name)
  }
  
  func visit(node: AstWildcardPattern) throws {
    print("w\(wildcardPatternCounter)")
    wildcardPatternCounter += 1
  }
  
  func visit(node: AstTuplePattern) throws {
    func expandTuple() throws {
      for pattern in node.patterns.dropLast() {
        print("(cons ")
        try pattern.accept(visitor: self)
        print(" ")
      }
      try node.patterns.last?.accept(visitor: self)
      for _ in node.patterns.dropLast() { print(")") }
    }
    
    func handleRootPattern() throws {
      guard let expression = caseExpressionStack.last?.expression else { return }
      print("(equal? ")
      caseTraversalStateStack.append(.nestedPattern)
      try expandTuple()
      _ = caseTraversalStateStack.popLast()
      print(" ")
      try expression.accept(visitor: self)
      print(")")
    }
    
    switch caseTraversalState {
    case .rootPattern:
      try handleRootPattern()
    case .nestedPattern:
      try expandTuple()
    case .binding:
      break
    case .none:
      if !dontPrintParents {
        print("(")
        if printList { print("list ") }
      }
      try perform(on: node.patterns, appending: " ")
      if !dontPrintParents { print(")") }
    }
  }
  
  func visit(node: AstConstantPattern) throws {
    print(node.value)
  }
  
  func visit(node: AstTypedPattern) throws {
    try node.pattern.accept(visitor: self)
  }
  
  func visit(node: AstEmptyListPattern) throws {
    switch caseTraversalState {
    case .rootPattern:
      guard let expression = caseExpressionStack.last?.expression else { return }
      print("(empty? ")
      try expression.accept(visitor: self)
      print(")")
    case .nestedPattern:
      print("todo")
    case .binding:
      break
    case .none:
      print("null")
    }
  }
  
  func visit(node: AstListPattern) throws {
    func handleRootPatternState() throws {
      func elementsCount() -> Int {
        var size = 0
        var pattern: AstPattern = node
        while let list = pattern as? AstListPattern {
          size += 1
          pattern = list.tail
        }
        return size - 1
      }
      
      func conditionsCount() -> Int {
        var count = 0
        var pattern: AstPattern = node
        while let list = pattern as? AstListPattern {
          count += list.head is AstIdentifierPattern ? 0 : 1
          pattern = list.tail
        }
        return count
      }
      
      guard let expression = caseExpressionStack.last else { return }
      let size = elementsCount()
      let conditions = conditionsCount()
      
      for _ in 0..<conditions { print("(and ") }
      
      print("(> (length ")
      try expression.expression.accept(visitor: self)
      print(") \(size)) ")
      
      if node.head is AstIdentifierPattern {}
      else {
        print("(equal? (car ")
        try expression.expression.accept(visitor: self)
        print(") ")
        caseTraversalStateStack.append(.nestedPattern)
        try node.head.accept(visitor: self)
        _ = caseTraversalStateStack.popLast()
        print(")")
      }
      
      for _ in 0..<conditions { print(")") }
    }
    
    func handleBindingState() throws {
      guard let expression = caseExpressionStack.last else { return }
      increaseIndent()
      newLine()
      
      var node = node
      var depth = 0
      
      while true {
        if node.head is AstIdentifierPattern {
          print("[")
          try node.head.accept(visitor: self)
          print(" ")
          
          print("(car ")
          for _ in 0..<depth { print("(cdr ") }
          try expression.expression.accept(visitor: self)
          for _ in 0..<depth + 1 { print(")") }
          print("]")
          newLine()
        }
        if let list = node.tail as? AstListPattern {
          node = list
          depth += 1
        } else if node.tail is AstIdentifierPattern {
          print("[")
          try node.tail.accept(visitor: self)
          print(" ")
          
          for _ in 0..<depth + 1 { print("(cdr ") }
          try expression.expression.accept(visitor: self)
          for _ in 0..<depth + 1 { print(")") }
          print("]")
          
          break
        } else {
          break
        }
      }
      decreaseIndent()
    }
    
    switch caseTraversalState {
    case .rootPattern:
      try handleRootPatternState()
    case .nestedPattern:
      print("TODO")
    case .binding:
      try handleBindingState()
    case .none:
      break
    }
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
     "tl": "cdr",
     "null": "null?"]
}

private extension RacketCodeGenerator {
  enum CaseExpressionTraversalState {
    case rootPattern
    case nestedPattern
    case binding
    case none
  }
  
  var caseTraversalState: CaseExpressionTraversalState {
    return caseTraversalStateStack.last ?? .none
  }
}
