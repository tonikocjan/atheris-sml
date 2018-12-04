//
//  AstIfExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstIfExpression: AstExpression {
  let position: Position
  let condition: AstExpression
  let trueBranch: AstExpression
  let falseBranch: AstExpression
  
  init(position: Position, condition: AstExpression, trueBranch: AstExpression, falseBranch: AstExpression) {
    self.position = position
    self.condition = condition
    self.trueBranch = trueBranch
    self.falseBranch = falseBranch
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
