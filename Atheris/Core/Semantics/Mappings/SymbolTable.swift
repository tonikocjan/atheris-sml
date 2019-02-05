//
//  SymbolTable.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class SymbolTable: SymbolTableProtocol {
  private typealias Bindigs = [AstBinding]
  
  public let symbolDescription: SymbolDescriptionProtocol
  private var mapping: [String: Bindigs] = [:]
  private var currentScopeDepth = 0
  
  public init(symbolDescription: SymbolDescriptionProtocol) {
    self.symbolDescription = symbolDescription
  }
  
  public func newScope() {
    currentScopeDepth += 1
  }
  
  public func oldScope() {
    removeBindingsFromCurrentScope()
    currentScopeDepth -= 1
  }
  
  public func addBindingToCurrentScope(name: String, binding: AstBinding) throws {
    guard let bindings = mapping[name] else {
      createBinding(name: name, binding: binding)
      setScope(currentScopeDepth, for: binding)
      return
    }
    
    guard try !isNameAlreadyUsedInCurrentScope(bindings: bindings) else {
      throw Error.bindingAlreadyExists(name)
    }
    
    insertBinding(name: name, binding: binding)
    setScope(currentScopeDepth, for: binding)
  }
  
  public func removeBindingFromCurrentScope(name: String) throws {
    guard let bindings = mapping[name], try isNameDefinedInCurrentOrGreaterScope(bindings: bindings) else {
      throw Error.bindingNotFound(name)
    }
    removeBinding(name: name)
  }
  
  public func findBinding(name: String) -> AstBinding? {
    guard let binding = mapping[name]?.first else { return nil }
    return binding
  }
}

extension SymbolTable {
  public enum Error: AtherisError {
    case bindingAlreadyExists(String)
    case bindingNotFound(String)
    case internalError([String])
    
    public var errorMessage: String {
      switch self {
      case .bindingAlreadyExists(let name): return "error: binding `\(name)` already exists"
      case .bindingNotFound(let name): return "error: binding `\(name)` not found"
      case .internalError(let dumpStack): return "internal error occured: \(dumpStack.joined(separator: "\n"))"
      }
    }
  }
}

private extension SymbolTable {
  func removeBindingsFromCurrentScope() {
    mapping.keys.forEach {
      try? removeBindingFromCurrentScope(name: $0)
    }
  }
  
  func createBinding(name: String, binding: AstBinding) {
    mapping[name] = [binding]
  }
  
  func insertBinding(name: String, binding: AstBinding) {
    mapping[name]?.insert(binding, at: 0) // TODO: - should probably optimize with LinkedList
  }
  
  func removeBinding(name: String) {
    mapping[name]?.remove(at: 0) // TODO: - again, should probably use LinkedList
    if (mapping[name]?.isEmpty ?? false) {
      mapping[name] = nil
    }
  }
  
  func setScope(_ scope: Int, for binding: AstBinding) {
    symbolDescription.setScope(for: binding, scope: currentScopeDepth)
  }
  
  private func isNameAlreadyUsedInCurrentScope(bindings: Bindigs) throws -> Bool {
    guard let first = bindings.first else { throw Error.internalError(Thread.callStackSymbols) }
    guard let bindingScope = symbolDescription.scope(for: first) else { throw Error.internalError(Thread.callStackSymbols) }
    return bindingScope == currentScopeDepth
  }
  
  private func isNameDefinedInCurrentOrGreaterScope(bindings: Bindigs) throws -> Bool {
    guard let first = bindings.first else { throw Error.internalError(Thread.callStackSymbols) }
    guard let bindingScope = symbolDescription.scope(for: first) else { throw Error.internalError(Thread.callStackSymbols) }
    return bindingScope >= currentScopeDepth
  }
}
