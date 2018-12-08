//
//  AstListExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstListExpression: AstExpression {
  let position: Position
  let elements: [AstExpression]
  
  init(position: Position, elements: [AstExpression]) {
    self.position = position
    self.elements = elements
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
