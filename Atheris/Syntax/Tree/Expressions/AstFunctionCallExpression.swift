//
//  AstFunctionCallExpression.swift
//  Atheris
//
//  Created by Toni Kocjan on 05/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstFunctionCallExpression: AstExpression {
  let position: Position
  let name: String
  let arguments: [AstExpression]
  
  init(position: Position, name: String, arguments: [AstExpression]) {
    self.position = position
    self.name = name
    self.arguments = arguments
  }
  
  func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
