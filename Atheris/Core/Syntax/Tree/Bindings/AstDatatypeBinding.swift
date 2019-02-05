//
//  AstDatatypeBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstDatatypeBinding: AstBinding {
  public let position: Position
  public let name: AstIdentifierPattern
  public let cases: [AstCase]
  public let types: [AstTypeBinding]
  
  public var pattern: AstPattern {
    return name
  }
  
  public init(position: Position, name: AstIdentifierPattern, cases: [AstCase], types: [AstTypeBinding]) {
    self.position = position
    self.name = name
    self.cases = cases
    self.types = types
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

public class AstCase: AstBinding {
  public let position: Position
  public let name: AstIdentifierPattern
  public let associatedType: AstType?
  public var pattern: AstPattern {
    return name
  }
  
  public init(position: Position, name: AstIdentifierPattern, associatedType: AstType?) {
    self.position = position
    self.name = name
    self.associatedType = associatedType
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
