//
//  AstNameExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstNameExpression: AstExpression {
  public let position: Position
  public let name: String
  
  public init(position: Position, name: String) {
    self.position = position
    self.name = name
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
