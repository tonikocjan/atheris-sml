//
//  AstBindings.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

struct AstBindings: AstNode {
  let position: Position
  let bindings: [AstBinding]
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}
