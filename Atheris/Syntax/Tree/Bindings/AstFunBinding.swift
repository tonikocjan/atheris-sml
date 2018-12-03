//
//  AstFunBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstFunBinding: AstBinding {
  let position: Position
  let pattern: AstPattern
  
  init(position: Position, pattern: AstPattern) {
    self.position = position
    self.pattern = pattern
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

//extension AstFunBinding {
//  var hashValue: Int {
//    return position.hashValue ^ pattern.hashValue
//  }
//
//  static func == (lhs: AstFunBinding, rhs: AstFunBinding) -> Bool {
//    return lhs.position == rhs.position
//  }
//}
