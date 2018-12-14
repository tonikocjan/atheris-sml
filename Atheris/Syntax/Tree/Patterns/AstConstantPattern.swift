//
//  AstConstantPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstConstantPattern: AstPattern, AstExpression {
  let position: Position
  let value: String
  let type: AstAtomType.AtomType
  var pattern: AstPattern { return self }
  
  init(position: Position, value: String, type: AstAtomType.AtomType) {
    self.position = position
    self.value = value
    self.type = type
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
