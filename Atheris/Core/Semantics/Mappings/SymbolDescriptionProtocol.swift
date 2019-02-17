//
//  SymbolDescriptionProtocol.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol SymbolDescriptionProtocol {
  func setScope(for node: AstBinding, scope: Int)
  func scope(for node: AstBinding) -> Int?
  func bindNode(_ node: AstNode, binding: AstBinding)
  func binding(for node: AstNode) -> AstBinding?
  func setType(for node: AstNode, type: Type)
  func type(for node: AstNode) -> Type?
}
