//
//  AstAnonymousFunctionCall.swift
//  Atheris
//
//  Created by Toni Kocjan on 06/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstAnonymousFunctionCall: AstFunctionCallExpression {
  public let function: AstExpression
  
  public init(position: Position, function: AstExpression, argument: AstExpression) {
    self.function = function
    super.init(position: position, name: "Anonymous", argument: argument)
  }
  
  public override func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
