//
//  AstNode.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol Visitable {
  func accept(visitor: AstVisitor) throws
}

public protocol AstNode: class, Visitable {
  var position: Position { get }
}
