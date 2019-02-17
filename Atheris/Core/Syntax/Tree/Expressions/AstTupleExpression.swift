//
//  AstTupleExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstTupleExpression: AstExpression {
  public let position: Position
  public let expressions: [AstExpression]
  
  public init(position: Position, expressions: [AstExpression]) {
    self.position = position
    self.expressions = expressions
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
