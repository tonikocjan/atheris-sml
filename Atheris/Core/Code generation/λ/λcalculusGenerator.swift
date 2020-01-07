//
//  λcalculusGenerator.swift
//  Atheris
//
//  Created by Toni Kocjan on 26/12/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

public class λcalculusGenerator: AstVisitor {
  private let symbolDescription: SymbolDescriptionProtocol
  private(set) var table = Table()
  
  public init(symbolDescription: SymbolDescriptionProtocol) {
    self.symbolDescription = symbolDescription
  }
}

public extension λcalculusGenerator {
  typealias Table = [NodeWrapper: Tree]
}

public extension λcalculusGenerator {
  func visit(node: AstBindings) throws {
    try node.bindings.forEach { try $0.accept(visitor: self) }
  }
  
  func visit(node: AstValBinding) throws {
    switch node.pattern {
    case let identifier as AstIdentifierPattern:
      var tree = try myVisit(node: node.expression)
      if !node.isGeneratedByCompiler {
        tree = .binding(v: identifier.name, expression: tree)
      }
      setTree(for: node, tree: tree)
    case _:
      fatalError("Not yet implemented")
    }
  }
  
  func visit(node: AstFunBinding) throws {
    guard node.cases.count == 1 else { fatalError("Not yet handled!") }
    
    switch node.cases[0].parameter {
    case let identifier as AstIdentifierPattern:
      let body = try myVisit(node: node.cases[0].body)
      let abstraction = Tree.abstraction(variable: identifier.name, expression: body)
      setTree(for: node, tree: .binding(v: node.identifier.name, expression: abstraction))
    case _:
      fatalError("Not yet implemented!")
    }
  }
  
  func visit(node: AstAnonymousFunctionBinding) throws {
    guard node.cases.count == 1 else { fatalError("Not yet handled!") }
    
    switch node.cases[0].parameter {
    case let identifier as AstIdentifierPattern:
      let body = try myVisit(node: node.cases[0].body)
      let abstraction = Tree.abstraction(variable: identifier.name, expression: body)
      setTree(for: node, tree: abstraction)
    case _:
      fatalError("Not yet implemented!")
    }
  }
  
  func visit(node: AstDatatypeBinding) throws {
    guard node.cases.count <= 25 else { fatalError("Datatype can contain at best 25 cases (for now)!") }
    
    let variables = (1...25) // the simplest strategy of choosing variable names ...
      .compactMap { UnicodeScalar($0 + 97) }
      .map { String($0) }
    
    func handleCase(_ c: AstCase, index: Int) -> (v: String, expression: Tree) {
      let n = node.cases.count
      let inner = Tree.application(fn: .variable(name: variables[index]),
                                   value: .variable(name: "a"))
      
      let abstraction = (1...n).reduce(inner) {
        Tree.abstraction(variable: variables[n - $1], expression: $0)
      }
        
      return (v: c.name.name, expression: .abstraction(variable: "a", expression: abstraction))
    }
    
    let datatype = node.cases
      .enumerated()
      .map { handleCase($0.element, index: $0.offset) }
    setTree(for: node, tree: .bindings(datatype))
  }
  
  func visit(node: AstCase) throws {
    fatalError("AstCase should be handled by the parent!")
  }
  
  func visit(node: AstTypeBinding) throws {}
  func visit(node: AstAtomType) throws {}
  func visit(node: AstTypeName) throws {}
  func visit(node: AstTypeConstructor) throws {}
  func visit(node: AstTupleType) throws {}
  
  func visit(node: AstConstantExpression) throws {
    switch (node.type, node.value) {
    case (.int, _), (.real, _):
      setTree(for: node, tree: .constant(value: Int(Double(node.value)!)))
    case (.bool, "true"):
      setTree(for: node, tree: λcalculusGenerator.TRUE)
    case (.bool, "false"):
      setTree(for: node, tree: λcalculusGenerator.FALSE)
    case _:
      fatalError("Not yet implemented")
    }
  }
  
  func visit(node: AstNameExpression) throws {
    setTree(for: node, tree: .variable(name: node.name))
  }
  
  func visit(node: AstTupleExpression) throws {
    let constructor = Tree.abstraction(variable: "e",
                                       expression: .abstraction(variable: "m",
                                                                expression: .abstraction(variable: "g",
                                                                                         expression: .application(fn: .application(fn: .variable(name: "g"),
                                                                                                                                   value: .variable(name: "e")),
                                                                                                                  value: .variable(name: "m")))))
    
    func createTuple(rows: [Tree]) -> Tree {
      if rows.count == 1 {
        return rows[0]
      }
      return .application(fn: .application(fn: constructor,
                                           value: rows[0]),
                                           value: createTuple(rows: Array(rows.dropFirst())))
    }
    
    let expressions = try node.expressions.map(myVisit)
    setTree(for: node, tree: .application(fn: .application(fn: constructor,
                                                           value: expressions[0]),
                                          value: createTuple(rows: Array(expressions.dropFirst()))))
  }
  
  func visit(node: AstBinaryExpression) throws {
    switch node.operation {
    case .add, .subtract, .multiply, .divide, .equal, .lessThan, .greaterThan:
      let left = try myVisit(node: node.left)
      let right = try myVisit(node: node.right)
      let application = Tree.application(fn: .application(fn: .variable(name: node.operation.rawValue),
                                                          value: left),
                                         value: right)
      setTree(for: node, tree: application)
    case _:
      fatalError("Binary operation \(node.operation.rawValue) is not (yet) supported!")
    }
  }
  
  func visit(node: AstUnaryExpression) throws {
    let expression = try myVisit(node: node.expression)
    switch node.operation {
    case .negate:
      let application = Tree.application(fn: .application(fn: .variable(name: "-"),
                                                          value: .constant(value: 0)),
                                         value: expression)
      setTree(for: node, tree: application)
    case .not:
      let application = Tree.application(fn: .application(fn: expression,
                                                          value: λcalculusGenerator.FALSE),
                                         value: λcalculusGenerator.TRUE)
      setTree(for: node, tree: application)
    }
  }
  
  func visit(node: AstIfExpression) throws {
    let condition = try myVisit(node: node.condition)
    let trueBranch = try myVisit(node: node.trueBranch)
    let falseBranch = try myVisit(node: node.falseBranch)
    let application = Tree.application(fn: .application(fn: condition, value: trueBranch),
                                       value: falseBranch)
    setTree(for: node, tree: application)
  }
  
  func visit(node: AstLetExpression) throws {
    
  }
  
  func visit(node: AstFunctionCallExpression) throws {
    let argument = try myVisit(node: node.argument)
    setTree(for: node, tree: .application(fn: .variable(name: node.name), value: argument))
  }
  
  func visit(node: AstAnonymousFunctionCall) throws {
    let function = try myVisit(node: node.function)
    let argument = try myVisit(node: node.argument)
    setTree(for: node, tree: .application(fn: function, value: argument))
  }
  
  func visit(node: AstRecordExpression) throws {}
  
  func visit(node: AstRecordRow) throws {}
  func visit(node: AstListExpression) throws {}
  
  func visit(node: AstRecordSelectorExpression) throws {
    let record = try myVisit(node: node.record)
    guard let tuple = type(for: node.record).toTuple else { fatalError("Records not yet covered!") }
    let index = Int(node.label.name)!
    let fst = Tree.abstraction(variable: "h",
                               expression: .application(fn: .variable(name: "h"),
                                                        value: .abstraction(variable: "a",
                                                                            expression: .abstraction(variable: "b",
                                                                                                     expression: .variable(name: "a")))))
    let snd = Tree.abstraction(variable: "i",
    expression: .application(fn: .variable(name: "i"),
                             value: .abstraction(variable: "c",
                                                 expression: .abstraction(variable: "d",
                                                                          expression: .variable(name: "d")))))
    let selector: Tree
    
    switch (index, tuple.rows.count) {
    case (1, 1...):
      selector = .application(fn: fst, value: record)
    case _ where index == tuple.rows.count && index > 2:
      selector = .application(fn: snd,
                              value: (1..<index - 2).reduce(Tree.application(fn: snd, value: record)) { tree, _ in Tree.application(fn: snd, value: tree) })
    case _ where index == tuple.rows.count:
      selector = .application(fn: snd,
                              value: record)
    case _:
      selector = .application(fn: fst,
                              value: (1..<index - 1).reduce(Tree.application(fn: snd, value: record)) { tree, _ in Tree.application(fn: snd, value: tree) })
    }
    
    setTree(for: node, tree: selector)
  }
  
  func visit(node: AstCaseExpression) throws {
    guard let datatype = (type(for: node.expression) as? CaseType)?.parent else { fatalError("Invalid type!") }
    guard let binding = datatype.binding as? AstDatatypeBinding else { fatalError("Invalid binding!") }
    
    func handleRule(_ rule: AstRule) throws -> Tree {
      let expression = try myVisit(node: rule.expression)
      
      if let associatedValue = rule.associatedValue {
        switch try myVisit(node: associatedValue) {
        case .variable(let v):
          return .abstraction(variable: v, expression: expression)
        case let tree:
          fatalError("Not yet handled!")
        }
      } else {
        return .abstraction(variable: "a", expression: expression)
      }
    }
    
    func index(of rule: AstRule) -> Int {
      binding.cases.firstIndex { $0.name.name == (rule.pattern as! AstIdentifierPattern).name }! // TODO: - this will carsh if pattern is not identifier!!
    }
    
    let expression = try myVisit(node: node.expression)
    let rules = try node.match.rules
      .sorted { index(of: $0) < index(of: $1) }
      .map(handleRule)

//    switch expression {
//    case .variable:
//      // need to manually provide a dummy value (0)
//      let application = rules.reduce(.application(fn: expression, value: .constant(value: 0))) { Tree.application(fn: $0, value: $1) }
//      setTree(for: node, tree: application)
//    case _:
      let application = rules.reduce(expression) { Tree.application(fn: $0, value: $1) }
      setTree(for: node, tree: application)
//    }
  }
  
  func visit(node: AstIdentifierPattern) throws {
    setTree(for: node, tree: .variable(name: node.name))
  }
  
  func visit(node: AstWildcardPattern) throws {}
  func visit(node: AstTuplePattern) throws {}
  
  func visit(node: AstConstantPattern) throws {}
  
  func visit(node: AstRecordPattern) throws {}
  func visit(node: AstTypedPattern) throws {}
  func visit(node: AstEmptyListPattern) throws {}
  func visit(node: AstListPattern) throws {}
  func visit(node: AstMatch) throws {}
  func visit(node: AstRule) throws {}
}

private extension λcalculusGenerator {
  func type(for node: AstNode) -> Type {
    guard let type = symbolDescription.type(for: node) else { fatalError("Type missing! Make sure type-checker is ran before code generation") }
    return type
  }
  
  func myVisit(node: AstNode) throws -> Tree {
    try node.accept(visitor: self)
    guard let tree = table[.init(node)] else { fatalError("Node couldn't have been mapped to a Tree. Exiting ...") }
    return tree
  }
  
  func setTree(for node: AstNode, tree: Tree) {
    table[.init(node)] = tree
  }
  
  ///
  
  static var TRUE: Tree {
    .abstraction(variable: "x",
                 expression: .abstraction(variable: "y",
                                          expression: .variable(name: "x")))
  }
  
  static var FALSE: Tree {
    .abstraction(variable: "x",
                 expression: .abstraction(variable: "y",
                                          expression: .variable(name: "y")))
  }
}
