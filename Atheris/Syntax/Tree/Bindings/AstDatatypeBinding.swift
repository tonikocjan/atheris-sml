//
//  AstDatatypeBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstDatatypeBinding: AstBinding {
  let position: Position
  let name: AstIdentifierPattern
  let cases: [AstCase]
  
  var pattern: AstPattern {
    return name
  }
  
  init(position: Position, name: AstIdentifierPattern, cases: [AstCase]) {
    self.position = position
    self.name = name
    self.cases = cases
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

class AstCase: AstBinding {
  let position: Position
  let name: AstIdentifierPattern
  let associatedType: AstType?
  var pattern: AstPattern {
    return name
  }
  
  init(position: Position, name: AstIdentifierPattern, associatedType: AstType?) {
    self.position = position
    self.name = name
    self.associatedType = associatedType
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
