//
//  AstTupleExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstTupleExpression: AstExpression {
  let position: Position
  let expressions: [AstExpression]
  
  init(position: Position, expressions: [AstExpression]) {
    self.position = position
    self.expressions = expressions
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
