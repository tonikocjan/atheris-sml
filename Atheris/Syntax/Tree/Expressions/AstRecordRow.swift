//
//  AstRecordRow.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstRecordRow: AstNode {
  public let position: Position
  public let label: AstIdentifierPattern
  public let expression: AstExpression
  
  public init(position: Position, label: AstIdentifierPattern, expression: AstExpression) {
    self.position = position
    self.label = label
    self.expression = expression
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
