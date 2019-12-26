//
//  λcalculusCodeGen.swift
//  Atheris
//
//  Created by Toni Kocjan on 26/12/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

public class λcalculusCodeGen: CodeGenerator {
  public let outputStream: OutputStream
  private let mapping: λcalculusGenerator.Table
  
  public init(outputStream: OutputStream, mapping: λcalculusGenerator.Table) {
    self.outputStream = outputStream
    self.mapping = mapping
  }
}

public extension λcalculusCodeGen {
  func visit(node: AstBindings) throws {
    _ = node.bindings
      .map { tree(for: $0).description }
      .map(outputStream.printLine)
  }
  
  func visit(node: AstValBinding) throws {
    
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

private extension λcalculusCodeGen {
  func tree(for node: AstNode) -> λcalculusGenerator.Tree {
    guard let tree = mapping[.init(node)] else { fatalError() }
    return tree
  }
}
