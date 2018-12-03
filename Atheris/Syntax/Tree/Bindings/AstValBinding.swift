//
//  AstValBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstValBinding: AstBinding {
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

//extension AstValBinding {
//  var hashValue: Int {
//    return position.hashValue ^ pattern.hashValue ^ expression.hashValue
//  }
//
//  static func == (lhs: AstValBinding, rhs: AstValBinding) -> Bool {
//    return lhs.position == rhs.position
//  }
//}

