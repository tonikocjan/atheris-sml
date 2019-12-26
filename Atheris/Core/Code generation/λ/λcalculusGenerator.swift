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
      let tree = Tree.binding(v: identifier.name, expression: try myVisit(node: node.expression))
      setLine(for: node, line: tree)
    case _:
      fatalError("Not yet implemented")
    }
  }
  
  func visit(node: AstFunBinding) throws {}
  func visit(node: AstAnonymousFunctionBinding) throws {}
  func visit(node: AstDatatypeBinding) throws {}
  func visit(node: AstCase) throws {}
  func visit(node: AstTypeBinding) throws {}
  func visit(node: AstAtomType) throws {}
  func visit(node: AstTypeName) throws {}
  func visit(node: AstTypeConstructor) throws {}
  func visit(node: AstTupleType) throws {}
  func visit(node: AstConstantExpression) throws {
    switch (node.type, node.value) {
    case (.int, _), (.real, _):
      setLine(for: node, line: .constant(value: Double(node.value)!))
    case (.bool, "true"):
      setLine(for: node, line: .abstraction(variable: "x",
                                            expression: .abstraction(variable: "y",
                                                                     expression: .variable(name: "x"))))
    case (.bool, "false"):
      setLine(for: node, line: .abstraction(variable: "x",
                                            expression: .abstraction(variable: "y",
                                                                     expression: .variable(name: "y"))))
    case _:
      fatalError("Not yet implemented")
    }
  }
  func visit(node: AstNameExpression) throws {}
  func visit(node: AstTupleExpression) throws {}
  func visit(node: AstBinaryExpression) throws {}
  func visit(node: AstUnaryExpression) throws {}
  func visit(node: AstIfExpression) throws {}
  func visit(node: AstLetExpression) throws {}
  func visit(node: AstFunctionCallExpression) throws {}
  func visit(node: AstAnonymousFunctionCall) throws {}
  func visit(node: AstRecordExpression) throws {}
  func visit(node: AstRecordRow) throws {}
  func visit(node: AstListExpression) throws {}
  func visit(node: AstRecordSelectorExpression) throws {}
  func visit(node: AstCaseExpression) throws {}
  func visit(node: AstIdentifierPattern) throws {}
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
    guard let line = table[.init(node)] else { fatalError() }
    return line
  }
  
  func setLine(for node: AstNode, line: Tree) {
    table[.init(node)] = line
  }
}
