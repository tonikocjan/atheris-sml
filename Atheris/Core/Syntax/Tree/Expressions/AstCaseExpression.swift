//
//  AstCaseExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstCaseExpression: AstExpression {
  public let position: Position
  public let expression: AstExpression
  public let match: AstMatch
  
  public init(position: Position, expression: AstExpression, match: AstMatch) {
    self.position = position
    self.expression = expression
    self.match = match
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
