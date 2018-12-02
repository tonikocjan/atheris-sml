//
//  AstValBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

struct AstValBinding: AstBinding {
  let position: Position
  let pattern: AstPattern
  let expression: AstExpression
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}
