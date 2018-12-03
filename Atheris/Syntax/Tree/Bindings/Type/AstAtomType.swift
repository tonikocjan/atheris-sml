//
//  AstAtomType.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstAtomType: AstType {
  let position: Position
  let identifier: String
  let type: AtomType
  
  init(position: Position, identifier: String, type: AtomType) {
    self.position = position
    self.identifier = identifier
    self.type = type
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
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
