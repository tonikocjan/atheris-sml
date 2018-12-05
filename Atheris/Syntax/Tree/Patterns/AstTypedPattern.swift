//
//  AstTypedPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstTypedPattern: AstPattern {
  let position: Position
  let pattern: AstPattern
  let type: AstType
  
  init(position: Position, pattern: AstPattern, type: AstType) {
    self.position = position
    self.pattern = pattern
    self.type = type
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
