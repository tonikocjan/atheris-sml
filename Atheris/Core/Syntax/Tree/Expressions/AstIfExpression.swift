//
//  AstIfExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstIfExpression: AstExpression {
  public let position: Position
  public let condition: AstExpression
  public let trueBranch: AstExpression
  public let falseBranch: AstExpression
  
  public init(position: Position, condition: AstExpression, trueBranch: AstExpression, falseBranch: AstExpression) {
    self.position = position
    self.condition = condition
    self.trueBranch = trueBranch
    self.falseBranch = falseBranch
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
