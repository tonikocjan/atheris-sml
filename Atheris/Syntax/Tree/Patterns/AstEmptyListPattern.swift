//
//  AstEmptyListPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class AstEmptyListPattern: AstPattern {
  let position: Position
  
  init(position: Position) {
    self.position = position
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
