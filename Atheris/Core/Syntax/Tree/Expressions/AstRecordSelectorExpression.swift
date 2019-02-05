//
//  AstRecordSelectorExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstRecordSelectorExpression: AstExpression {
  public let position: Position
  public let label: AstIdentifierPattern
  public let record: AstExpression
  
  public init(position: Position, label: AstIdentifierPattern, record: AstExpression) {
    self.position = position
    self.label = label
    self.record = record
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
