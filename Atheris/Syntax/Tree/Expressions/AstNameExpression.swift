//
//  AstNameExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstNameExpression: AstExpression {
  let position: Position
  let name: String
  
  init(position: Position, name: String) {
    self.position = position
    self.name = name
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
