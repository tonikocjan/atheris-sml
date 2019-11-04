//
//  JSONVisitor.swift
//  Atheris
//
//  Created by Toni Kocjan on 18/10/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class JSONVisitor {
  let outputStream: OutputStream
  let symbolDescription: SymbolDescriptionProtocol?
  
  convenience init(outputStream: OutputStream) {
    self.init(outputStream: outputStream, symbolDescription: nil)
  }
  
  init(outputStream: OutputStream, symbolDescription: SymbolDescriptionProtocol?) {
    self.outputStream = outputStream
    self.symbolDescription = symbolDescription
  }
  
  private var isRootNode = true
  private var indent = 0
  private let indentIncrement = 2
}

extension JSONVisitor: AstVisitor {
  public func visit(node: AstBindings) throws {
    let isRootNode = self.isRootNode
    _ = {
      self.isRootNode = false
      increaseIndentObject()
      printJSON("node", "Bindings")
      print(",")
      printSemanticInformation(node: node)
      print("\"children\": ")
      increaseIndentList()
      commaSeparated(list: node.bindings)
      decreaseIndentList()
      decreaseIndentObject()
    }()
    if isRootNode {
    }
  }
  
  public func visit(node: AstValBinding) throws {
    increaseIndentObject()
    printJSON("node", "Val Binding")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.pattern, node.expression])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstFunBinding) throws {
    increaseIndentObject()
    printJSON("node", "Fun Binding")
    print(",")
    printSemanticInformation(node: node)
//    try node.identifier.accept(visitor: self)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.cases) {
      commaSeparated(list: [$0.parameter, $0.resultType, $0.body].compactMap { $0 })
    }
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstAnonymousFunctionBinding) throws {
    increaseIndentObject()
    printJSON("node", "λ Binding")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.cases) {
      commaSeparated(list: [$0.parameter, $0.body])
    }
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstDatatypeBinding) throws {
    increaseIndentObject()
    printJSON("node", "DataType Binding")
    print(",")
    printSemanticInformation(node: node)
//    try node.name.accept(visitor: self)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.cases)
//    for type in node.types { try type.accept(visitor: self) }
//    for case_ in node.cases { try case_.accept(visitor: self) }
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstCase) throws {
    increaseIndentObject()
    printSemanticInformation(node: node)
    printJSON("node", "Case")
//    try node.name.accept(visitor: self)
    decreaseIndentObject()
  }
  
  public func visit(node: AstTypeBinding) throws {
    increaseIndentObject()
    printJSON("node", "Type Binding")
    print(",")
    printSemanticInformation(node: node)
    try node.identifier.accept(visitor: self)
    printJSON("type", "\(node.type == .normal ? "'" : "''")")
    decreaseIndentObject()
  }
  
  public func visit(node: AstAtomType) throws {
    increaseIndentObject()
    printJSON("node", "Atom Type")
    print(",")
    printSemanticInformation(node: node)
    printJSON("name", node.name)
//    print("Atom type: " + node.type.rawValue)
    decreaseIndentObject()
  }
  
  public func visit(node: AstTypeName) throws {
    increaseIndentObject()
    printJSON("node", "Type Name")
    print(",")
    printSemanticInformation(node: node)
    printJSON("name", node.name)
    decreaseIndentObject()
  }
  
  public func visit(node: AstTypeConstructor) throws {
    increaseIndentObject()
    printJSON("node", "Type Constructor")
    print(",")
    printSemanticInformation(node: node)
    printJSON("name", node.name)
    print(",")
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.types)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstTupleType) throws {
    increaseIndentObject()
    printJSON("node", "Tuple Type")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.types)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstConstantExpression) throws {
    increaseIndentObject()
    printJSON("node", "Constant Expression")
    print(",")
    printSemanticInformation(node: node)
    printJSON("value", node.value)
//    print("Atom type: " + node.type.rawValue)
    decreaseIndentObject()
  }
  
  public func visit(node: AstNameExpression) throws {
    increaseIndentObject()
    printJSON("node", "Name Expression")
    print(",")
    printSemanticInformation(node: node)
    printJSON("value", node.name)
    decreaseIndentObject()
  }
  
  public func visit(node: AstTupleExpression) throws {
    increaseIndentObject()
    printJSON("node", "Tuple Expression")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.expressions)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstBinaryExpression) throws {
    increaseIndentObject()
    printJSON("node", "Binary Expression")
    print(",")
    printJSON("value", node.operation.rawValue)
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.left, node.right])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstUnaryExpression) throws {
    increaseIndentObject()
    printJSON("node", "Unary Expression")
    print(",")
    printJSON("value", node.operation.rawValue)
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    try node.expression.accept(visitor: self)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstIfExpression) throws {
    increaseIndentObject()
    printJSON("node", "If Expression")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.condition, node.trueBranch, node.falseBranch])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstLetExpression) throws {
    increaseIndentObject()
    printJSON("node", "Let Expression")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.bindings, node.expression])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstFunctionCallExpression) throws {
    increaseIndentObject()
    printJSON("node", "Fun Call Expression")
    print(",")
    printSemanticInformation(node: node)
    printJSON("name", node.name)
    print(",")
    print("\"children\": ")
    increaseIndentList()
    try node.argument.accept(visitor: self)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstAnonymousFunctionCall) throws {
    increaseIndentObject()
    printJSON("node", "λ Expression")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.argument, node.function])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstRecordExpression) throws {
    increaseIndentObject()
    printJSON("node", "Record Expression")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.rows)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstCaseExpression) throws {
    increaseIndentObject()
    printJSON("node", "Case Expression")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.expression, node.match])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstRecordRow) throws {
    increaseIndentObject()
    printJSON("node", "Record Row")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.label, node.expression])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstListExpression) throws {
    increaseIndentObject()
    printJSON("node", "List Expression")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.elements)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstRecordSelectorExpression) throws {
    increaseIndentObject()
    printJSON("node", "Record Selector Expression")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.label, node.record])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstIdentifierPattern) throws {
    increaseIndentObject()
    printJSON("node", "Identifier Pattern")
    print(",")
    printSemanticInformation(node: node)
    printJSON("value", node.name)
    decreaseIndentObject()
  }
  
  public func visit(node: AstWildcardPattern) throws {
    printSemanticInformation(node: node)
  }
  
  public func visit(node: AstTuplePattern) throws {
    increaseIndentObject()
    printJSON("node", "Tupple Pattern")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.patterns)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstRecordPattern) throws {
    increaseIndentObject()
    printJSON("node", "Record Pattern")
    print(",")
    printSemanticInformation(node: node)
    decreaseIndentObject()
  }
  
  public func visit(node: AstConstantPattern) throws {
    increaseIndentObject()
    printJSON("node", "Tupple Pattern")
    print(",")
    printJSON("value", node.value)
    print(",")
    printSemanticInformation(node: node)
    decreaseIndentObject()
  }
  
  public func visit(node: AstEmptyListPattern) throws {
    increaseIndentObject()
    printSemanticInformation(node: node)
    decreaseIndentObject()
  }
  
  public func visit(node: AstListPattern) throws {
    increaseIndentObject()
    printJSON("node", "List Pattern")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.head, node.tail])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstTypedPattern) throws {
    increaseIndentObject()
    printJSON("node", "Tyoed Pattern")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.pattern, node.type])
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstMatch) throws {
    increaseIndentObject()
    printJSON("node", "Match")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: node.rules)
    decreaseIndentList()
    decreaseIndentObject()
  }
  
  public func visit(node: AstRule) throws {
    increaseIndentObject()
    printJSON("node", "Rule")
    print(",")
    printSemanticInformation(node: node)
    print("\"children\": ")
    increaseIndentList()
    commaSeparated(list: [node.pattern, node.associatedValue, node.expression].compactMap { $0 })
    decreaseIndentList()
    decreaseIndentObject()
  }
}

private extension JSONVisitor {
  func print(_ string: String, _ position: Position) {
    outputStream.print("\(withIndent(string)) \(position.description):")
  }
  
  func printJSON(_ a: String, _ b: String) {
    outputStream.print(withIndent("\"\(a)\": \"\(b)\""))
  }
  
  func print(_ string: String) {
    outputStream.print(withIndent(string))
  }
  
  func withIndent(_ string: String) -> String {
    return (0..<indent).reduce("", { acc, _ in acc + " " }) + string
  }
  
  func increaseIndentObject() {
    print("{")
//    indent += indentIncrement
  }
  
  func decreaseIndentObject() {
//    indent -= indentIncrement
    print("}")
  }
  
  func increaseIndentList() {
    print("[")
//    indent += indentIncrement
  }
  
  func decreaseIndentList() {
//    indent -= indentIncrement
    print("]")
  }
  
  func printSemanticInformation(node: AstNode) {
    guard let symbolDescription = symbolDescription else { return }
    
    var comma = false
    
    if let binding = symbolDescription.binding(for: node) {
      printJSON("definedAt", binding.position.description)
      comma = true
    }
    
    if let type = symbolDescription.type(for: node) {
      if comma { print(",") }
      printJSON("typed", type.description)
      print(",")
    }
  }
  
  func commaSeparated(list: [AstNode]) {
    for (index, element) in list.enumerated() {
      try? element.accept(visitor: self)
      if index + 1 < list.count {
        print(",")
      }
    }
  }
  
    func commaSeparated<T>(list: [T], perform callback: (T) -> Void) {
      for (index, element) in list.enumerated() {
        callback(element)
        if index + 1 < list.count {
          print(",")
        }
      }
    }
}
