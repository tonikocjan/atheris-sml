//
//  SymbolDescription.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class SymbolDescription: SymbolDescriptionProtocol {
  private var scopeMapping: [NodeWrapper: Int] = [:]
  private var definitionsMapping: [NodeWrapper: AstBinding] = [:]
  private var typeMapping: [NodeWrapper: Type] = [:]
  
  func setScope(for node: AstBinding, scope: Int) {
    scopeMapping[NodeWrapper(node)] = scope
  }
  
  func scope(for node: AstBinding) -> Int? {
    return scopeMapping[NodeWrapper(node)]
  }
  
  func bindNode(_ node: AstNode, binding: AstBinding) {
    definitionsMapping[NodeWrapper(node)] = binding
  }
  
  func binding(for node: AstNode) -> AstBinding? {
    return definitionsMapping[NodeWrapper(node)]
  }
  
  func type(for node: AstNode) -> Type? {
    return typeMapping[NodeWrapper(node)]
  }
  
  func setType(for node: AstNode, type: Type) {
    typeMapping[NodeWrapper(node)] = type
  }
}

private extension SymbolDescription {
  class NodeWrapper: Hashable {
    let node: AstNode
    private lazy var hashValue_: Int = { return ObjectIdentifier(self.node).hashValue }()
    
    init(_ node: AstNode) {
      self.node = node
    }
    
    public var hashValue: Int {
      return hashValue_
    }
    
    static func == (lhs: NodeWrapper, rhs: NodeWrapper) -> Bool {
      return lhs.node === rhs.node
    }
  }
}
