//
//  AstRecordExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstRecordExpression: AstExpression {
  let position: Position
  let rows: [AstRecordRow]
  
  init(position: Position, rows: [AstRecordRow]) {
    self.position = position
    self.rows = rows
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
