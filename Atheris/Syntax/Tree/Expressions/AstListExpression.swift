//
//  AstListExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstListExpression: AstExpression {
  public let position: Position
  public let elements: [AstExpression]
  
  public init(position: Position, elements: [AstExpression]) {
    self.position = position
    self.elements = elements
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
