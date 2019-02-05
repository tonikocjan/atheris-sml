//
//  AstMatch.swift
//  Atheris
//
//  Created by Toni Kocjan on 07/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstMatch: AstNode {
  public let position: Position
  public let rules: [AstRule]
  
  public init(position: Position, rules: [AstRule]) {
    self.position = position
    self.rules = rules
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
