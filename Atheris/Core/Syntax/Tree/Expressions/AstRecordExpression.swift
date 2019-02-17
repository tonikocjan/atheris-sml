//
//  AstRecordExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstRecordExpression: AstExpression {
  public let position: Position
  public let rows: [AstRecordRow]
  
  public init(position: Position, rows: [AstRecordRow]) {
    self.position = position
    self.rows = rows
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
