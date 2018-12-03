//
//  AstWildcardPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstWildcardPattern: AstPattern {
  let position: Position
  
  init(position: Position) {
    self.position = position
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

//extension AstWildcardPattern {
//  var hashValue: Int {
//    return position.hashValue ^ name.hashValue
//  }
//
//  static func == (lhs: AstWildcardPattern, rhs: AstWildcardPattern) -> Bool {
//    return lhs.position == rhs.position
//  }
//}
