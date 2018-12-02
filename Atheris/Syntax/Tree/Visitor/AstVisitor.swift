//
//  AstVisitor.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol AstVisitor {
  func visit(node: AstBindings)
  func visit(node: AstValBinding)
  func visit(node: AstFunBinding)
  func visit(node: AstAtomType)
  func visit(node: AstConstantExpression)
  func visit(node: AstIdentifierPattern)
  func visit(node: AstWildcardPattern)
  func visit(node: AstTuplePattern)
  func visit(node: AstRecordPattern)
}
