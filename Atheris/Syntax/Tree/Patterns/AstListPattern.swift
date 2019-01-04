//
//  AstListPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class AstListPattern: AstPattern {
  let position: Position
  let head: AstPattern
  let tail: AstPattern
  
  init(position: Position, head: AstPattern, tail: AstPattern) {
    self.position = position
    self.head = head
    self.tail = tail
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
