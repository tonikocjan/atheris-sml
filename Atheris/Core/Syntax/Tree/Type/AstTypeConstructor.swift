//
//  AstTypeConstructor.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstTypeConstructor: AstType {
  public let position: Position
  public let name: String
  public let types: [AstType]
  
  public init(position: Position, name: String, types: [AstType]) {
    self.position = position
    self.name = name
    self.types = types
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
