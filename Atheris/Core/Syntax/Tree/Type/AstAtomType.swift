//
//  AstAtomType.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstAtomType: AstType {
  public let position: Position
  public let name: String
  public let type: AtomType
  
  public init(position: Position, name: String, type: AtomType) {
    self.position = position
    self.name = name
    self.type = type
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}

extension AstAtomType {
  public enum AtomType: String {
    case int
    case real
    case string
    case bool
  }
}
