//
//  AstLetExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 05/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstLetExpression: AstExpression {
  public let position: Position
  public let bindings: AstBindings
  public let expression: AstExpression
  
  public init(position: Position, bindings: AstBindings, expression: AstExpression) {
    self.position = position
    self.bindings = bindings
    self.expression = expression
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
