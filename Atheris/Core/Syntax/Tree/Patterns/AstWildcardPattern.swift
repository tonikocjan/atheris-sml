//
//  AstWildcardPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstWildcardPattern: AstPattern {
  public let position: Position
  
  public init(position: Position) {
    self.position = position
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
