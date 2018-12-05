//
//  AstBindings.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstBindings: AstNode {
  let position: Position
  let bindings: [AstBinding]
  
  init(position: Position, bindings: [AstBinding]) {
    self.position = position
    self.bindings = bindings
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
