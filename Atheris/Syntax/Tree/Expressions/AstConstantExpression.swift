//
//  AstConstantExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

struct AstConstantExpression: AstExpression {
  let position: Position
  let value: String
  let type: AstAtomType.AtomType
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}
