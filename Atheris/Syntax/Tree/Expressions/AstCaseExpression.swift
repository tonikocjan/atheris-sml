//
//  AstCaseExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstCaseExpression: AstExpression {
  let position: Position
  let expression: AstExpression
  let match: AstMatch
  
  init(position: Position, expression: AstExpression, match: AstMatch) {
    self.position = position
    self.expression = expression
    self.match = match
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
