//
//  RacketCodeGenerator.swift
//  Atheris
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class RacketCodeGenerator {
  let outputStream: OutputStream
  let configuration: Configuration
  
  private var isRootNode = true
  private var indent = 0
  
  init(outputStream: OutputStream, configuration: Configuration) {
    self.outputStream = outputStream
    self.configuration = configuration
  }
}

extension RacketCodeGenerator {
  struct Configuration {
    let indentation: Int
    let pretty: Bool
    
    static let standard = Configuration(indentation: 2, pretty: true)
  }
}

// MARK: - CodeGenerator
extension RacketCodeGenerator: CodeGenerator {
  func visit(node: AstBindings) throws {
    if isRootNode {
      print("#lang racket\n")
      newLine()
      isRootNode = false
    }
    
    for binding in node.bindings {
      try binding.accept(visitor: self)
      newLine()
    }
  }
  
  func visit(node: AstValBinding) throws {
    print("(define ")
    try node.pattern.accept(visitor: self)
    print(" ")
    try node.expression.accept(visitor: self)
    print(")")
  }
  
  func visit(node: AstFunBinding) throws {
    
  }
  
  func visit(node: AstAtomType) throws {
    
  }
  
  func visit(node: AstTypeName) throws {
    
  }
  
  func visit(node: AstTupleType) throws {
    
  }
  
  func visit(node: AstConstantExpression) throws {
    print(node.value)
  }
  
  func visit(node: AstNameExpression) throws {
    print(node.name)
  }
  
  func visit(node: AstTupleExpression) throws {
    
  }
  
  func visit(node: AstBinaryExpression) throws {
    let operation: String
    switch node.operation {
    case .add,
         .subtract,
         .multiply,
         .divide,
         .lessThan,
         .greaterThan,
         .equal,
         .lessThanOrEqual,
         .greaterThanOrEqual:
      operation = node.operation.rawValue
    case .andalso:
      operation = "and"
    case .orelse:
      operation = "or"
    }
    print("(\(operation) ")
    try node.left.accept(visitor: self)
    print(" ")
    try node.right.accept(visitor: self)
    print(")")
  }
  
  func visit(node: AstUnaryExpression) throws {
    
  }
  
  func visit(node: AstIfExpression) throws {
    
  }
  
  func visit(node: AstIdentifierPattern) throws {
    print(node.name)
  }
  
  func visit(node: AstWildcardPattern) throws {
    
  }
  
  func visit(node: AstTuplePattern) throws {
    
  }
  
  func visit(node: AstRecordPattern) throws {
    
  }
  
  func visit(node: AstTypedPattern) throws {
    
  }
}

private extension RacketCodeGenerator {
  func print(_ string: String) {
    outputStream.print(string)
  }
  
  func indentation() -> String {
    return (0..<indent).map { _ in " " }.joined()
  }
  
  func newLine() {
    guard configuration.pretty else { return }
    outputStream.printLine("")
    outputStream.print(indentation())
  }
  
  func increaseIndent() { indent += configuration.indentation }
  func decreaseIndent() { indent -= configuration.indentation }
}
