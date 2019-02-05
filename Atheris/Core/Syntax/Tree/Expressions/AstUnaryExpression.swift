//
//  AstUnaryExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstUnaryExpression: AstExpression {
  public let position: Position
  public let operation: Operation
  public let expression: AstExpression
  
  public init(position: Position, operation: Operation, expression: AstExpression) {
    self.position = position
    self.operation = operation
    self.expression = expression
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

extension AstUnaryExpression {
  public enum Operation: String {
    case negate = "~"
    case not = "not"
  }
}
