//
//  AstAnonymousFunctionCall.swift
//  Atheris
//
//  Created by Toni Kocjan on 06/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstAnonymousFunctionCall: AstFunctionCallExpression {
  let function: AstExpression
  
  init(position: Position, function: AstExpression, argument: AstExpression) {
    self.function = function
    super.init(position: position, name: "Anonymous", argument: argument)
  }
  
  override func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
