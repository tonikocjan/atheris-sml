//
//  AstIdentifierPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

struct AstIdentifierPattern: AstPattern {
  let position: Position
  let name: String
  let type: AstType?
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}
