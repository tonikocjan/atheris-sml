//
//  AstVisitor.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol AstVisitor {
  func visit(node: AstBindings) throws
  func visit(node: AstValBinding) throws
  func visit(node: AstFunBinding) throws
  func visit(node: AstAnonymousFunctionBinding) throws
  func visit(node: AstDatatypeBinding) throws
  func visit(node: AstCase) throws
  func visit(node: AstTypeBinding) throws
  func visit(node: AstAtomType) throws
  func visit(node: AstTypeName) throws
  func visit(node: AstTypeConstructor) throws
  func visit(node: AstTupleType) throws
  func visit(node: AstConstantExpression) throws
  func visit(node: AstNameExpression) throws
  func visit(node: AstTupleExpression) throws
  func visit(node: AstBinaryExpression) throws
  func visit(node: AstUnaryExpression) throws
  func visit(node: AstIfExpression) throws
  func visit(node: AstLetExpression) throws
  func visit(node: AstFunctionCallExpression) throws
  func visit(node: AstAnonymousFunctionCall) throws
  func visit(node: AstRecordExpression) throws
  func visit(node: AstRecordRow) throws
  func visit(node: AstListExpression) throws
  func visit(node: AstRecordSelectorExpression) throws
  func visit(node: AstCaseExpression) throws
  func visit(node: AstIdentifierPattern) throws
  func visit(node: AstWildcardPattern) throws
  func visit(node: AstConstantPattern) throws
  func visit(node: AstTuplePattern) throws
  func visit(node: AstRecordPattern) throws
  func visit(node: AstTypedPattern) throws
  func visit(node: AstEmptyListPattern) throws
  func visit(node: AstListPattern) throws
  func visit(node: AstMatch) throws
  func visit(node: AstRule) throws
}

extension AstVisitor {
  public func visit(node: AstBindings) throws {}
  public func visit(node: AstValBinding) throws {}
  public func visit(node: AstFunBinding) throws {}
  public func visit(node: AstAnonymousFunctionBinding) throws {}
  public func visit(node: AstDatatypeBinding) throws {}
  public func visit(node: AstCase) throws {}
  public func visit(node: AstTypeBinding) throws {}
  public func visit(node: AstAtomType) throws {}
  public func visit(node: AstTypeName) throws {}
  public func visit(node: AstTypeConstructor) throws {}
  public func visit(node: AstTupleType) throws {}
  public func visit(node: AstConstantExpression) throws {}
  public func visit(node: AstNameExpression) throws {}
  public func visit(node: AstTupleExpression) throws {}
  public func visit(node: AstBinaryExpression) throws {}
  public func visit(node: AstUnaryExpression) throws {}
  public func visit(node: AstIfExpression) throws {}
  public func visit(node: AstLetExpression) throws {}
  public func visit(node: AstFunctionCallExpression) throws {}
  public func visit(node: AstAnonymousFunctionCall) throws {}
  public func visit(node: AstRecordExpression) throws {}
  public func visit(node: AstRecordRow) throws {}
  public func visit(node: AstListExpression) throws {}
  public func visit(node: AstRecordSelectorExpression) throws {}
  public func visit(node: AstCaseExpression) throws {}
  public func visit(node: AstIdentifierPattern) throws {}
  public func visit(node: AstWildcardPattern) throws {}
  public func visit(node: AstTuplePattern) throws {}
  public func visit(node: AstConstantPattern) throws {}
  public func visit(node: AstRecordPattern) throws {}
  public func visit(node: AstTypedPattern) throws {}
  public func visit(node: AstEmptyListPattern) throws {}
  public func visit(node: AstListPattern) throws {}
  public func visit(node: AstMatch) throws {}
  public func visit(node: AstRule) throws {}
}
