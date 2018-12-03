//
//  AstRecordPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstRecordPattern: AstPattern {
  let position: Position
  
  init(position: Position) {
    self.position = position
  }
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}

//extension AstTuplePattern {
//  var hashValue: Int {
//    return position.hashValue
//  }
//  
//  static func == (lhs: AstTuplePattern, rhs: AstTuplePattern) -> Bool {
//    return lhs.position == rhs.position
//  }
//}
