//
//  AstTypeBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 11/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class AstTypeBinding: AstBinding {
  let position: Position
  let identifier: AstIdentifierPattern
  let type: Kind
  var pattern: AstPattern { return identifier }
  
  init(position: Position, identifier: AstIdentifierPattern, type: Kind) {
    self.position = position
    self.identifier = identifier
    self.type = type
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

extension AstTypeBinding {
  enum Kind: String {
    case normal = "'"
    case equatable = "''"
  }
  
  var name: String {
    return type.rawValue + identifier.name
  }
}
