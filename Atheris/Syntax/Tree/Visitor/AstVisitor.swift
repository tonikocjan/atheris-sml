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
  func visit(node: AstAtomType) throws
  func visit(node: AstTypeName) throws
  func visit(node: AstTupleType) throws
  func visit(node: AstConstantExpression) throws
  func visit(node: AstNameExpression) throws
  func visit(node: AstTupleExpression) throws
  func visit(node: AstIdentifierPattern) throws
  func visit(node: AstWildcardPattern) throws
  func visit(node: AstTuplePattern) throws
  func visit(node: AstRecordPattern) throws
  func visit(node: AstTypedPattern) throws
}
