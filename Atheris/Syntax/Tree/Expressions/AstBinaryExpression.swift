//
//  AstBinaryExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstBinaryExpression: AstExpression {
  let position: Position
  let operation: Operation
  let left: AstExpression
  let right: AstExpression
  
  init(position: Position, operation: Operation, left: AstExpression, right: AstExpression) {
    self.position = position
    self.operation = operation
    self.left = left
    self.right = right
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

extension AstBinaryExpression {
  enum Operation: String {
    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = "/"
    case concat = "^"
    case lessThan = "<"
    case greaterThan = ">"
    case equal = "="
    case lessThanOrEqual = "<="
    case greaterThanOrEqual = ">="
    case andalso = "andalso"
    case orelse = "orelse"
    case append = "::"
  }
}
