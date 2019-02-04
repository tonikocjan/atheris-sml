//
//  AstListPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstListPattern: AstPattern {
  public let position: Position
  public let head: AstPattern
  public let tail: AstPattern
  
  public init(position: Position, head: AstPattern, tail: AstPattern) {
    self.position = position
    self.head = head
    self.tail = tail
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
