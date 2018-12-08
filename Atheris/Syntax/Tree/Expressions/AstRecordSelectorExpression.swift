//
//  AstRecordSelectorExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstRecordSelectorExpression: AstExpression {
  let position: Position
  let label: AstIdentifierPattern
  let record: AstExpression
  
  init(position: Position, label: AstIdentifierPattern, record: AstExpression) {
    self.position = position
    self.label = label
    self.record = record
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
