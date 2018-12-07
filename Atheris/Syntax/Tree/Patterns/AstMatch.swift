//
//  AstMatch.swift
//  Atheris
//
//  Created by Toni Kocjan on 07/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstMatch: AstNode {
  let position: Position
  let rules: [AstRule]
  
  init(position: Position, rules: [AstRule]) {
    self.position = position
    self.rules = rules
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

class AstRule: AstNode {
  let position: Position
  let pattern: AstPattern
  let expression: AstExpression
  
  init(position: Position, pattern: AstPattern, expression: AstExpression) {
    self.position = position
    self.pattern = pattern
    self.expression = expression
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
