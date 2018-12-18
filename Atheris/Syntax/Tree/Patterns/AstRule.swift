//
//  AstRule.swift
//  Atheris
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstRule: AstNode {
  let position: Position
  let pattern: AstPattern
  let associatedValue: AstPattern?
  let expression: AstExpression
  
  init(position: Position, pattern: AstPattern, associatedValue: AstPattern?, expression: AstExpression) {
    self.position = position
    self.pattern = pattern
    self.associatedValue = associatedValue
    self.expression = expression
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
