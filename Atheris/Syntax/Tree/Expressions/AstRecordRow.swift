//
//  AstRecordRow.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstRecordRow: AstNode {
  let position: Position
  let label: AstIdentifierPattern
  let expression: AstExpression
  
  init(position: Position, label: AstIdentifierPattern, expression: AstExpression) {
    self.position = position
    self.label = label
    self.expression = expression
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
