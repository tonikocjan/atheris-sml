//
//  AstFunBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstFunBinding: AstBinding {
  struct Case {
    let parameter: AstPattern
    let body: AstExpression
    let resultType: AstType?
  }
  
  let position: Position
  let identifier: AstIdentifierPattern
  let cases: [Case]
  var pattern: AstPattern {
    return identifier
  }
  
  init(position: Position, identifier: AstIdentifierPattern, parameter: AstPattern, body: AstExpression) {
    self.position = position
    self.identifier = identifier
    self.cases = [Case(parameter: parameter, body: body, resultType: nil)]
  }
  
  init(position: Position, identifier: AstIdentifierPattern, cases: [Case]) {
    self.position = position
    self.identifier = identifier
    self.cases = cases
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
