//
//  AstTupleType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstTupleType: AstType {
  let position: Position
  let types: [AstType]
  
  init(position: Position, types: [AstType]) {
    self.position = position
    self.types = types
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
