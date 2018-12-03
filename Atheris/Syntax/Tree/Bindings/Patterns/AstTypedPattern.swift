//
//  AstTypedPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

struct AstTypedPattern: AstPattern {
  let position: Position
  let pattern: AstPattern
  let type: AstType
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}
