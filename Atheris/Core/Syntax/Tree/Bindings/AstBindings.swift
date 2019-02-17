//
//  AstBindings.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstBindings: AstNode {
  public let position: Position
  public let bindings: [AstBinding]
  
  public init(position: Position, bindings: [AstBinding]) {
    self.position = position
    self.bindings = bindings
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
