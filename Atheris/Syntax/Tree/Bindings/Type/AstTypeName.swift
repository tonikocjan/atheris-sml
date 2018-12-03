//
//  AstTypeName.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AstTypeName: AstType {
  let position: Position
  let identifier: String
  
  init(position: Position, identifier: String) {
    self.position = position
    self.identifier = identifier
  }
  
  func accept(visitor: AstVisitor) {
    visitor.visit(node: self)
  }
}
