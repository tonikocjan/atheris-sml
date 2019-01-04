//
//  AstVisitor.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol AstVisitor {
  func visit(node: AstBindings) throws
  func visit(node: AstValBinding) throws
  func visit(node: AstFunBinding) throws
  func visit(node: AstAnonymousFunctionBinding) throws
  func visit(node: AstDatatypeBinding) throws
  func visit(node: AstCase) throws
  func visit(node: AstAtomType) throws
  func visit(node: AstTypeName) throws
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
  func visit(node: AstBindings) throws {}
  func visit(node: AstValBinding) throws {}
  func visit(node: AstFunBinding) throws {}
  func visit(node: AstAnonymousFunctionBinding) throws {}
  func visit(node: AstDatatypeBinding) throws {}
  func visit(node: AstCase) throws {}
  func visit(node: AstAtomType) throws {}
  func visit(node: AstTypeName) throws {}
  func visit(node: AstTupleType) throws {}
  func visit(node: AstConstantExpression) throws {}
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
