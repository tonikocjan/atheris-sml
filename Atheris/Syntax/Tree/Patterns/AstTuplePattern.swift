//
//  AstTuplePattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstTuplePattern: AstPattern {
  let position: Position
  let patterns: [AstPattern]
  
  init(position: Position, patterns: [AstPattern]) {
    self.position = position
    self.patterns = patterns
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
