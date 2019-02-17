//
//  AstTypeBinding.swift
//  Atheris
//
//  Created by Toni Kocjan on 11/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstTypeBinding: AstBinding {
  public let position: Position
  public let identifier: AstIdentifierPattern
  public let type: Kind
  public var pattern: AstPattern { return identifier }
  
  public init(position: Position, identifier: AstIdentifierPattern, type: Kind) {
    self.position = position
    self.identifier = identifier
    self.type = type
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

extension AstTypeBinding {
  public enum Kind: String {
    case normal = "'"
    case equatable = "''"
  }
  
  public var name: String {
    return type.rawValue + identifier.name
  }
}
