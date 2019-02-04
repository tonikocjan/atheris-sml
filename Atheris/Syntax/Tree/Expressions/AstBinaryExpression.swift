//
//  AstBinaryExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstBinaryExpression: AstExpression {
  public let position: Position
  public let operation: Operation
  public let left: AstExpression
  public let right: AstExpression
  
  public init(position: Position, operation: Operation, left: AstExpression, right: AstExpression) {
    self.position = position
    self.operation = operation
    self.left = left
    self.right = right
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

extension AstBinaryExpression {
  public enum Operation: String {
    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = "/"
    case modulo = "mod"
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
