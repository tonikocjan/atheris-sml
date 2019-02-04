//
//  AstFunBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstFunBinding: AstBinding {
  public let position: Position
  public let identifier: AstIdentifierPattern
  public let cases: [Case]
  public var pattern: AstPattern {
    return identifier
  }
  
  public init(position: Position, identifier: AstIdentifierPattern, parameter: AstPattern, body: AstExpression) {
    self.position = position
    self.identifier = identifier
    self.cases = [Case(parameter: parameter, body: body, resultType: nil)]
  }
  
  public init(position: Position, identifier: AstIdentifierPattern, cases: [Case]) {
    self.position = position
    self.identifier = identifier
    self.cases = cases
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

extension AstFunBinding {
  public struct Case {
    let parameter: AstPattern
    let body: AstExpression
    let resultType: AstType?
  }
}
