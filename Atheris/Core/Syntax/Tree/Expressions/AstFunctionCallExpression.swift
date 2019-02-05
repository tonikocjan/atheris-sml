//
//  AstFunctionCallExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 05/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstFunctionCallExpression: AstExpression {
  public let position: Position
  public let name: String
  public let argument: AstExpression
  
  public init(position: Position, name: String, argument: AstExpression) {
    self.position = position
    self.name = name
    self.argument = argument
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
