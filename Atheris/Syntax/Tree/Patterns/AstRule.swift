//
//  AstRule.swift
//  Atheris
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstRule: AstNode {
  public let position: Position
  public let pattern: AstPattern
  public let associatedValue: AstPattern?
  public let expression: AstExpression
  
  public init(position: Position, pattern: AstPattern, associatedValue: AstPattern?, expression: AstExpression) {
    self.position = position
    self.pattern = pattern
    self.associatedValue = associatedValue
    self.expression = expression
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
