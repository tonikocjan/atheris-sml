//
//  AstLetExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 05/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstLetExpression: AstExpression {
  let position: Position
  let bindings: AstBindings
  let expression: AstExpression
  
  init(position: Position, bindings: AstBindings, expression: AstExpression) {
    self.position = position
    self.bindings = bindings
    self.expression = expression
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
