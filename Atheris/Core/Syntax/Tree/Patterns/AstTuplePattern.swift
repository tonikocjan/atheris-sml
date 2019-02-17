//
//  AstTuplePattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstTuplePattern: AstPattern {
  public let position: Position
  public let patterns: [AstPattern]
  
  public init(position: Position, patterns: [AstPattern]) {
    self.position = position
    self.patterns = patterns
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
