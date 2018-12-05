//
//  AstFunBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstFunBinding: AstBinding {
  let position: Position
  let identifier: AstIdentifierPattern
  let parameters: [AstPattern]
  let body: AstExpression
  var pattern: AstPattern {
    return identifier
  }
  
  init(position: Position, identifier: AstIdentifierPattern, parameters: [AstPattern], body: AstExpression) {
    self.position = position
    self.identifier = identifier
    self.parameters = parameters
    self.body = body
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
