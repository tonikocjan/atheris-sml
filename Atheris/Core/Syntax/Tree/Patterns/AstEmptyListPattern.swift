//
//  AstEmptyListPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstEmptyListPattern: AstPattern {
  public let position: Position
  
  public init(position: Position) {
    self.position = position
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
