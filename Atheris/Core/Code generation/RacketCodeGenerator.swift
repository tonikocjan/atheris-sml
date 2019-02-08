//
//  RacketCodeGenerator.swift
//  Atheris
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class RacketCodeGenerator {
  public let outputStream: OutputStream
  public let configuration: Configuration
  public let symbolDescription: SymbolDescriptionProtocol
  
  private var buffer: String?
  
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
  private var bindingCodeStack = [String]()
  private var caseTraversalStateStack = [CaseExpressionTraversalState]()
  // each node in stack is used for single `AstCaseExpr
  // new nestedPatterns and counters are pushed for each nested `AstCaseExpr`
  private var nestedPatternsStack = [[(pattern: AstPattern, binding: String)]]()
  
  public init(outputStream: OutputStream, configuration: Configuration, symbolDescription: SymbolDescriptionProtocol) {
    self.outputStream = outputStream
    self.configuration = configuration
    self.symbolDescription = symbolDescription
  }
}

extension RacketCodeGenerator {
  public struct Configuration {
    let indentation: Int
    let pretty: Bool
    let printWelcome: Bool
    
    static let standard = Configuration(indentation: 2, pretty: true, printWelcome: true)
  }
}

// MARK: - CodeGenerator
extension RacketCodeGenerator: CodeGenerator {
  public func visit(node: AstBindings) throws {
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
  
  public func visit(node: AstValBinding) throws {
    print("(define ")
    try node.pattern.accept(visitor: self)
    print(" ")
    rhs = true
    try node.expression.accept(visitor: self)
    rhs = false
    print(")")
  }
  
  public func visit(node: AstFunBinding) throws {
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
        if let caseType = pattern as? CaseType {
          print("\(caseType.name)?")
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
  
  public func visit(node: AstAnonymousFunctionBinding) throws {
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
  
  public func visit(node: AstDatatypeBinding) throws {
    expandingDatatypeCaseType = true
    try perform(on: node.cases, appending: "") {
      self.newLine()
      self.expandingDatatypeCaseCounter = 0
    }
    expandingDatatypeCaseType = false
  }
  
  public func visit(node: AstCase) throws {
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
  
  public func visit(node: AstAtomType) throws {
    guard expandingDatatypeCaseType else { return }
    print("x\(expandingDatatypeCaseCounter)")
    expandingDatatypeCaseCounter += 1
  }
  
  public func visit(node: AstTypeName) throws {
    guard expandingDatatypeCaseType else { return }
    print("x\(expandingDatatypeCaseCounter)")
    expandingDatatypeCaseCounter += 1
  }
  
  public func visit(node: AstTupleType) throws {
    guard expandingDatatypeCaseType else { return }
    try perform(on: node.types, appending: " ")
  }
  
  public func visit(node: AstConstantExpression) throws {
    print(node.type == .string ? "\"\(node.value)\"" : node.value)
  }
  
  public func visit(node: AstNameExpression) throws {
    guard let type = symbolDescription.type(for: node) else { return }
    
    func isDatatypeConstructorWithoutAssociatedValue() -> Bool {
      guard rhs && !printList else { return false }
      guard type is CaseType || (type as? FunctionType)?.body is CaseType else { return false }
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
  
  public func visit(node: AstTupleExpression) throws {
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
  
  public func visit(node: AstBinaryExpression) throws {
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
  
  public func visit(node: AstUnaryExpression) throws {
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
  
  public func visit(node: AstIfExpression) throws {
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
  
  public func visit(node: AstLetExpression) throws {
    try node.bindings.accept(visitor: self)
    try node.expression.accept(visitor: self)
  }
  
  public func visit(node: AstFunctionCallExpression) throws {
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
  
  public func visit(node: AstAnonymousFunctionCall) throws {
    print("(")
    try node.function.accept(visitor: self)
    print(" ")
    dontPrintParents = true
    try node.argument.accept(visitor: self)
    dontPrintParents = false
    print(")")
  }
  
  public func visit(node: AstRecordExpression) throws {
    print("(list ")
    try perform(on: node.rows, appending: " ")
    print(")")
  }
  
  public func visit(node: AstRecordRow) throws {
    print("(cons \"")
    try node.label.accept(visitor: self)
    print("\" ")
    try node.expression.accept(visitor: self)
    print(")")
  }
  
  public func visit(node: AstRecordSelectorExpression) throws {
    print("(cdr ")
    print("(assoc ")
    print("\"")
    try node.label.accept(visitor: self)
    print("\" ")
    try node.record.accept(visitor: self)
    print("))")
  }
  
  public func visit(node: AstListExpression) throws {
    guard !node.elements.isEmpty else {
      print("null")
      return
    }
    print("(list ")
    try perform(on: node.elements, appending: " ")
    print(")")
  }
  
  public func visit(node: AstCaseExpression) throws {
    caseExpressionStack.append(node)
    try node.match.accept(visitor: self)
    _ = caseExpressionStack.popLast()
  }
  
  public func visit(node: AstMatch) throws {
    func handlePattern(rule: AstRule) throws {
      caseTraversalStateStack.append(.rootPattern)
      
      try resolvePatternMatching(pattern: rule.pattern)
      guard let patterns = nestedPatternsStack.last else { return }
      if patterns.count > 1 {
        print("(and ")
        increaseIndent()
        newLine()
      }
      for (pattern, code) in patterns {
        bindingCodeStack.append(code)
        try pattern.accept(visitor: self)
        _ = bindingCodeStack.popLast()
        newLine()
      }
      if patterns.count > 1 {
        print(")")
        decreaseIndent()
        newLine()
      }
      _ = caseTraversalStateStack.popLast()
    }
    
    func handleBinding(rule: AstRule) throws {
      caseTraversalStateStack.append(.binding)
      print("(let (")
      if let associatedValue = rule.associatedValue {
        try handleAssociatedValue(associatedValue, rule: rule)
        _ = nestedPatternsStack.popLast()
      } else {
        guard let type = symbolDescription.type(for: rule) as? RuleType else { return }
        if type.patternType is CaseType {
          _ = nestedPatternsStack.popLast()
        } else {
          increaseIndent()
          var shouldPrintNewLine = true
          
          guard let patterns = nestedPatternsStack.last else { return }
          for (pattern, code) in patterns {
            bindingCodeStack.append(code)
            self.buffer = ""
            try pattern.accept(visitor: self)
            _ = bindingCodeStack.popLast()
            if let buffer = self.buffer, !buffer.isEmpty {
              self.buffer = nil
              if shouldPrintNewLine {
                newLine()
                shouldPrintNewLine = false
              }
              print(buffer)
              newLine()
            }
            self.buffer = nil
          }
          decreaseIndent()
          _ = nestedPatternsStack.popLast()
        }
      }
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
  
  public func visit(node: AstIdentifierPattern) throws {
    func handleRootPattern() throws {
      guard let expression = caseExpressionStack.last?.expression else { return }
      print("(\(node.name)? ")
      try expression.accept(visitor: self)
      print(")")
    }
    
    func handleBinding() throws {
      print(node.name)
    }
    
    switch caseTraversalState {
    case .rootPattern:
      try handleRootPattern()
    case .nestedPattern:
      print(node.name)
    case .binding:
      try handleBinding()
    case .none:
      print(node.name)
    }
  }
  
  public func visit(node: AstWildcardPattern) throws {
    print("w\(wildcardPatternCounter)")
    wildcardPatternCounter += 1
  }
  
  public func visit(node: AstTuplePattern) throws {
    func expandTuple() throws {
      for pattern in node.patterns.dropLast() {
        print("(cons ")
        try pattern.accept(visitor: self)
        print(" ")
      }
      try node.patterns.last?.accept(visitor: self)
      for _ in node.patterns.dropLast() { print(")") }
    }
    
    switch caseTraversalState {
    case .rootPattern:
      break
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
  
  public func visit(node: AstConstantPattern) throws {
    switch caseTraversalState {
    case .rootPattern:
      guard let code = bindingCodeStack.last else { return }
      print("(equal? \(code) \(node.value))")
    case .binding:
      break
    case .nestedPattern, .none:
      print(node.value)
    }
  }
  
  public func visit(node: AstTypedPattern) throws {
    try node.pattern.accept(visitor: self)
  }
  
  public func visit(node: AstEmptyListPattern) throws {
    switch caseTraversalState {
    case .rootPattern:
      guard let code = bindingCodeStack.last else { return }
      print("(null? \(code))")
    case .nestedPattern:
      throw NSError(domain: "atheris.racket.generator.error", code: 99, userInfo: ["error": "not yet implemented"])
    case .binding:
      break
    case .none:
      print("null")
    }
  }
  
  public func visit(node: AstListPattern) throws {
    func handleRootPatternState() throws {
      func elementsCount() -> Int {
        var index = 0
        var result = -1
        var pattern: AstPattern = node
        while let list = pattern as? AstListPattern {
          if list.head is AstIdentifierPattern { result = index }
          index += 1
          pattern = list.tail
        }
        return result > -1 ? result : index - 1
      }
      
      guard let code = bindingCodeStack.last else { return }
      let count = elementsCount()
      if count == 0 {
        print("(not (empty? \(code)))")
      } else {
        print("(> (length \(code)) \(count))")
      }
    }
    
    func handleBindingState() throws {
      guard let code = bindingCodeStack.last else { return }
      
      var node = node
      var depth = 0
      
      while true {
        if node.head is AstIdentifierPattern {
          print("[")
          try node.head.accept(visitor: self)
          print(" ")
          
          print("(car ")
          for _ in 0..<depth { print("(cdr ") }
          print(code)
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
          print(code)
          for _ in 0..<depth + 1 { print(")") }
          print("]")
          
          break
        } else {
          break
        }
      }
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
    if let _ = buffer {
      print(string, into: &self.buffer!)
    } else {
      outputStream.print(string)
    }
  }
  
  func print(_ string: String, into buffer: inout String) {
    buffer += string
  }
  
  func indentation() -> String {
    return (0..<indent)
      .reduce("", { result, _ in result + " " })
  }
  
  func newLine() {
    guard configuration.pretty else { return }
    print("\n")
    print(indentation())
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
  func resolvePatternMatching(pattern: AstPattern) throws {
    guard let expression = caseExpressionStack.last else { return }
    let expressionCode = try generateCode(for: expression.expression)
    
    switch pattern {
    case is AstTuplePattern:
      try resolveTuplePattern(pattern: pattern as! AstTuplePattern,
                              expressionCode: expressionCode)
    case is AstConstantPattern:
      try resolveConstantPattern(pattern: pattern as! AstConstantPattern,
                                 expressionCode: expressionCode)
    case is AstListPattern:
      try resolveListPattern(pattern: pattern as! AstListPattern,
                             expressionCode: expressionCode)
    case is AstEmptyListPattern:
      try resolveEmptyListPattern(pattern: pattern as! AstEmptyListPattern,
                                  expressionCode: expressionCode)
    case is AstIdentifierPattern:
      try resolveIdentifierPattern(pattern: pattern as! AstIdentifierPattern,
                                   expressionCode: expressionCode)
    default:
      break
    }
  }
  
  func resolveTuplePattern(pattern: AstTuplePattern, expressionCode: String) throws {
    func wrapExpression(index: Int) -> String {
      var code = ""
      for _ in 0..<index { code += "(cdr " }
      code += expressionCode
      for _ in 0..<index { code += ")" }
      if index + 1 == pattern.patterns.count {
        return code
      }
      return "(car \(code))"
    }
    
    for (index, subpattern) in pattern.patterns.enumerated() {
      let indexed = wrapExpression(index: index)
      
      switch subpattern {
      case is AstTuplePattern:
        try resolveTuplePattern(pattern: subpattern as! AstTuplePattern,
                                expressionCode: indexed)
      case is AstEmptyListPattern:
        try resolveEmptyListPattern(pattern: subpattern as! AstEmptyListPattern,
                                    expressionCode: indexed)
      case is AstListPattern:
        try resolveListPattern(pattern: subpattern as! AstListPattern,
                               expressionCode: indexed)
      case is AstConstantPattern:
        pushPattern(subpattern, binding: indexed)
      case is AstIdentifierPattern:
        pushPattern(subpattern, binding: indexed)
      default:
        break
      }
    }
  }
  
  func resolveConstantPattern(pattern: AstConstantPattern, expressionCode: String) throws {
    pushPattern(pattern, binding: expressionCode)
  }
  
  func resolveListPattern(pattern: AstListPattern, expressionCode: String) throws {
    func wrapExpression(index: Int, car: Bool) -> String {
      var code = ""
      for _ in 0..<index { code += "(cdr " }
      code += expressionCode
      for _ in 0..<index { code += ")" }
      if car {
        return "(car \(code))"
      }
      return code
    }
    
    pushPattern(pattern, binding: expressionCode)
    
    var pattern: AstPattern = pattern
    var index = 0
    while let list = pattern as? AstListPattern {
      let wrapped = wrapExpression(index: index, car: true)
      
      switch list.head {
      case is AstListPattern:
        try resolveListPattern(pattern: list.head as! AstListPattern,
                               expressionCode: wrapped)
      case is AstTuplePattern:
        try resolveTuplePattern(pattern: list.head as! AstTuplePattern,
                                expressionCode: wrapped)
      case is AstConstantPattern:
        pushPattern(list.head, binding: wrapped)
      case is AstEmptyListPattern:
        pushPattern(list.head, binding: wrapped)
      default:
        break
      }
      index += 1
      pattern = list.tail
    }
    if let empty = pattern as? AstEmptyListPattern {
      pushPattern(empty, binding: wrapExpression(index: index, car: false))
    }
  }
  
  func resolveEmptyListPattern(pattern: AstEmptyListPattern, expressionCode: String) throws {
    pushPattern(pattern, binding: expressionCode)
  }
  
  func resolveIdentifierPattern(pattern: AstIdentifierPattern, expressionCode: String) throws {
    pushPattern(pattern, binding: expressionCode)
  }
  
  func generateCode(for node: AstNode) throws -> String {
    self.buffer = ""
    try node.accept(visitor: self)
    let result = self.buffer!
    self.buffer = nil
    return result
  }
  
  func pushPattern(_ pattern: AstPattern, binding: String) {
    let tuple = (pattern: pattern, binding: binding)
    if var patterns = nestedPatternsStack.last {
      patterns.append(tuple)
      nestedPatternsStack[nestedPatternsStack.count - 1] = patterns
    } else {
      nestedPatternsStack.append([tuple])
    }
  }
  
  func handleAssociatedValue(_ associatedValue: AstPattern, rule: AstRule) throws {
    func expandTuple(tuple: AstTuplePattern, expression: AstExpression) throws {
      var tuplePatternsCounter = 0
      func expand(tuple: AstTuplePattern) throws {
        increaseIndent()
        newLine()
        for pattern in tuple.patterns {
          if let subPattern = pattern as? AstTuplePattern {
            try expandTuple(tuple: subPattern, expression: expression)
            continue
          }
          
          print("[")
          try pattern.accept(visitor: self)
          print(" (")
          try rule.pattern.accept(visitor: self)
          print("-x\(tuplePatternsCounter)")
          tuplePatternsCounter += 1
          print(" ")
          try expression.accept(visitor: self)
          print(")]")
          if pattern === tuple.patterns.last {}
          else { newLine() }
        }
      }
      try expand(tuple: tuple)
      decreaseIndent()
      newLine()
    }
    
    guard let expression = caseExpressionStack.last?.expression else { return }
    guard let type = symbolDescription.type(for: rule) as? RuleType else { return }
    
    if let tuple = associatedValue as? AstTuplePattern {
      try expandTuple(tuple: tuple, expression: expression)
    } else {
      self.print("[")
      try associatedValue.accept(visitor: self)
      self.print(" ")
      if let identifierPattern = rule.pattern as? AstIdentifierPattern, type.patternType is CaseType {
        self.print("(\(identifierPattern.name)-x0 ")
        try expression.accept(visitor: self)
        self.print(")")
      } else {
        try expression.accept(visitor: self)
      }
      self.print("]")
    }
  }
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
