//
//  AstConstantExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstConstantExpression: AstExpression {
  let position: Position
  let value: String
  let type: AstAtomType.AtomType
  
  init(position: Position, value: String, type: AstAtomType.AtomType) {
    self.position = position
    self.value = value
    self.type = type
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

//extension AstConstantExpression {
//  var hashValue: Int {
//    return position.hashValue ^ value.hashValue ^ type.hashValue
//  }
//
//  static func == (lhs: AstConstantExpression, rhs: AstConstantExpression) -> Bool {
//    return lhs.position == rhs.position
//  }
//}
