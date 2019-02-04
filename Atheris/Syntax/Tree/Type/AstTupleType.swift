//
//  AstTupleType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstTupleType: AstType {
  public let position: Position
  public let types: [AstType]
  
  public init(position: Position, types: [AstType]) {
    self.position = position
    self.types = types
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
