//
//  AstTypedPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstTypedPattern: AstPattern {
  public let position: Position
  public let pattern: AstPattern
  public let type: AstType
  
  public init(position: Position, pattern: AstPattern, type: AstType) {
    self.position = position
    self.pattern = pattern
    self.type = type
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
