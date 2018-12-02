//
//  AstAtomType.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

struct AstAtomType: AstType {
  let position: Position
  let name: String
  let type: AtomType
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}

extension AstAtomType {
  enum AtomType: String {
    case int
    case real
    case string
    case bool
  }
}
