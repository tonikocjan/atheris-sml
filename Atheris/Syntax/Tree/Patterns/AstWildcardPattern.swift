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
