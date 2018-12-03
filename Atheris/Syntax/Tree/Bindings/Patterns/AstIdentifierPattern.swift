//
//  AstIdentifierPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstIdentifierPattern: AstPattern, AstBinding {
  let position: Position
  let name: String
  var pattern: AstPattern { return self }
  
  init(position: Position, name: String) {
    self.position = position
    self.name = name
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

//extension AstIdentifierPattern {
//  var hashValue: Int {
//    return position.hashValue ^ name.hashValue
//  }
//
//  static func == (lhs: AstIdentifierPattern, rhs: AstIdentifierPattern) -> Bool {
//    return lhs.position == rhs.position
//  }
//}
