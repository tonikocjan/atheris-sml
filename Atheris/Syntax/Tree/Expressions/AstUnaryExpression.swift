//
//  AstUnaryExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstUnaryExpression: AstExpression {
  let position: Position
  let operation: Operation
  let expression: AstExpression
  
  init(position: Position, operation: Operation, expression: AstExpression) {
    self.position = position
    self.operation = operation
    self.expression = expression
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

extension AstUnaryExpression {
  enum Operation: String {
    case negate = "~"
  }
}
