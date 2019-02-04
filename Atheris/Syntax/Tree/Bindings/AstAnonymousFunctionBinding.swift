//
//  AstAnonymousFunctionBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 06/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstAnonymousFunctionBinding: AstFunBinding, AstExpression {
  public init(position: Position, parameter: AstPattern, body: AstExpression) {
    super.init(position: position,
               identifier: AstIdentifierPattern(position: position, name: "Anonymous"),
               parameter: parameter,
               body: body)
  }
  
  public override func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
