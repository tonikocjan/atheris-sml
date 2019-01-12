//
//  AstTypeConstructor.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class AstTypeConstructor: AstType {
  let position: Position
  let name: String
  let types: [AstType]
  
  init(position: Position, name: String, types: [AstType]) {
    self.position = position
    self.name = name
    self.types = types
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
