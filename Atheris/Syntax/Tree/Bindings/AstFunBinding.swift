//
//  AstFunBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

struct AstFunBinding: AstBinding {
  let position: Position
  let pattern: AstPattern
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}
