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
  
  func visit(node: AstDatatypeBinding) throws {}
  func visit(node: AstCase) throws {}
  func visit(node: AstTypeBinding) throws {}
  func visit(node: AstAtomType) throws {}
  func visit(node: AstTypeName) throws {}
  func visit(node: AstTypeConstructor) throws {}
  func visit(node: AstTupleType) throws {}
  
  func visit(node: AstConstantExpression) throws {
    switch (node.type, node.value) {
    case (.int, _):
      setTree(for: node, tree: .constant(value: Int(node.value)!))
    case (.bool, "true"):
      setTree(for: node, tree: .abstraction(variable: "x",
                                            expression: .abstraction(variable: "y",
                                                                     expression: .variable(name: "x"))))
    case (.bool, "false"):
      setTree(for: node, tree: .abstraction(variable: "x",
                                            expression: .abstraction(variable: "y",
                                                                     expression: .variable(name: "y"))))
    case _:
      fatalError("Not yet implemented")
    }
  }
  
  func visit(node: AstNameExpression) throws {
    setTree(for: node, tree: .variable(name: node.name))
  }
  
  func visit(node: AstTupleExpression) throws {}
  
  func visit(node: AstBinaryExpression) throws {
    switch node.operation {
    case .add, .subtract, .multiply, .divide, .equal:
      let left = try myVisit(node: node.left)
      let right = try myVisit(node: node.right)
      let application = Tree.application(fn: .application(fn: .variable(name: node.operation.rawValue),
                                                          value: left),
                                         value: right)
      setTree(for: node, tree: application)
    case _:
      fatalError("This binary operation is not (yet) supported!")
    }
  }
  
  func visit(node: AstUnaryExpression) throws {}
  
  func visit(node: AstIfExpression) throws {
    let condition = try myVisit(node: node.condition)
    let trueBranch = try myVisit(node: node.trueBranch)
    let falseBranch = try myVisit(node: node.falseBranch)
    let application = Tree.application(fn: .application(fn: condition, value: trueBranch),
                                       value: falseBranch)
    setTree(for: node, tree: application)
  }
  
  func visit(node: AstLetExpression) throws {}
  
  func visit(node: AstFunctionCallExpression) throws {
    let argument = try myVisit(node: node.argument)
    setTree(for: node, tree: .application(fn: .variable(name: node.name),
                                          value: argument))
  }
  
  func visit(node: AstAnonymousFunctionCall) throws {
    let function = try myVisit(node: node.function)
    let argument = try myVisit(node: node.argument)
    setTree(for: node, tree: .application(fn: function, value: argument))
  }
  
  func visit(node: AstRecordExpression) throws {}
  func visit(node: AstRecordRow) throws {}
  func visit(node: AstListExpression) throws {}
  func visit(node: AstRecordSelectorExpression) throws {}
  func visit(node: AstCaseExpression) throws {}
  
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
}
