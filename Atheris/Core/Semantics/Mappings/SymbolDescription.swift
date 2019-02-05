//
//  SymbolDescription.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class SymbolDescription: SymbolDescriptionProtocol {
  private var scopeMapping: [NodeWrapper: Int] = [:]
  private var definitionsMapping: [NodeWrapper: AstBinding] = [:]
  private var typeMapping: [NodeWrapper: Type] = [:]
  
  public func setScope(for node: AstBinding, scope: Int) {
    scopeMapping[NodeWrapper(node)] = scope
  }
  
  public func scope(for node: AstBinding) -> Int? {
    return scopeMapping[NodeWrapper(node)]
  }
  
  public func bindNode(_ node: AstNode, binding: AstBinding) {
    definitionsMapping[NodeWrapper(node)] = binding
  }
  
  public func binding(for node: AstNode) -> AstBinding? {
    return definitionsMapping[NodeWrapper(node)]
  }
  
  public func type(for node: AstNode) -> Type? {
    return typeMapping[NodeWrapper(node)]
  }
  
  public func setType(for node: AstNode, type: Type) {
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
