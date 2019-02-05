//
//  AstConstantPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstConstantPattern: AstPattern, AstExpression {
  public let position: Position
  public let value: String
  public let type: AstAtomType.AtomType
  public var pattern: AstPattern { return self }
  
  public init(position: Position, value: String, type: AstAtomType.AtomType) {
    self.position = position
    self.value = value
    self.type = type
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
