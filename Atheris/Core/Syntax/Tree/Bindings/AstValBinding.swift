//
//  AstValBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstValBinding: AstBinding {
  public let position: Position
  public let pattern: AstPattern
  public let expression: AstExpression
  public var isGeneratedByCompiler = false
  
  public init(position: Position, pattern: AstPattern, expression: AstExpression) {
    self.position = position
    self.pattern = pattern
    self.expression = expression
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
