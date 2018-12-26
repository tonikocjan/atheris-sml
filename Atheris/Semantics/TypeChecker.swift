//
//  TypeChecker.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class TypeChecker {
  let symbolTable: SymbolTableProtocol
  let symbolDescription: SymbolDescriptionProtocol
  
  // MARK: - dummy types
  private static let dummyTypeCharacterSet = Array("A1B1C1D1E1F1G1H1I1J1K1L1M1N1O1P1R1S1T1V1U1Z1ABCDEFGHIJKLMNOPRSTVUZ".reversed())
  private var dummyTypeCount = 0
  
  // MARK: - Internal stacks
  private var typeDistributionStack = [Type]()
  private var funEvalStack = [AstFunBinding]()
  
  //
  private var currentDatatypeName: String?
  private var valBindingRhs = false
  
  init(symbolTable: SymbolTableProtocol, symbolDescription: SymbolDescriptionProtocol) {
    self.symbolTable = symbolTable
    self.symbolDescription = symbolDescription
  }
}

extension TypeChecker: AstVisitor {
  func visit(node: AstBindings) throws {
    for binding in node.bindings { try binding.accept(visitor: self) }
  }
  
  func visit(node: AstValBinding) throws {
    valBindingRhs = true
    try node.expression.accept(visitor: self)
    valBindingRhs = false
    try node.pattern.accept(visitor: self)
    
    guard let expressionType = symbolDescription.type(for: node.expression) else { throw internalError() }
    
    let resultType: Type
    
    if let patternType = symbolDescription.type(for: node.pattern) {
      guard patternType.sameStructureAs(other: expressionType) else {
        throw Error.typeError(position: node.position, patternType: patternType, expressionType: expressionType)
      }
      if let function = expressionType.asFunction, function.body is DatatypeType, function.parameter.isAbstract {
        symbolDescription.setType(for: node, type: function.body)
        resultType = function.body
      } else {
        symbolDescription.setType(for: node, type: expressionType)
        resultType = expressionType
      }
    } else {
      // expression's type is assigned to pattern and node
      symbolDescription.setType(for: node.pattern, type: expressionType)
      symbolDescription.setType(for: node, type: expressionType)
      resultType = expressionType
    }
    
    // distribute top-level type to child nodes
    typeDistributionStack.append(resultType)
    try node.pattern.accept(visitor: self)
    _ = typeDistributionStack.popLast()
  }
  
  func visit(node: AstFunBinding) throws {
    funEvalStack.append(node)
    try node.identifier.accept(visitor: self)
    var parameterType: Type?
    var bodyType: Type?
    
    for case_ in node.cases {
      try case_.parameter.accept(visitor: self)
      try case_.body.accept(visitor: self)
      try case_.parameter.accept(visitor: self)
      guard let parameterType_ = symbolDescription.type(for: case_.parameter) else { throw internalError() }
      guard let bodyType_ = symbolDescription.type(for: case_.body) else { throw internalError() }
      if node.cases.count > 1 {
        guard !parameterType_.isAbstract else {
          throw Error.redundantCaseError(position: case_.parameter.position)
        }
      }
      
      if let parameterType = parameterType, let bodyType = bodyType {
        guard parameterType_.sameStructureAs(other: parameterType) else {
          throw Error.typeError(position: case_.parameter.position, patternType: parameterType, expressionType: parameterType_)
        }
        guard bodyType_.sameStructureAs(other: bodyType) else {
          throw Error.typeError(position: case_.body.position, patternType: bodyType, expressionType: bodyType_)
        }
      } else {
        parameterType = parameterType_
        bodyType = bodyType_
      }
    }
    
    let functionType = FunctionType(name: node.identifier.name,
                                    parameter: parameterType!,
                                    body: bodyType!)
    symbolDescription.setType(for: node, type: functionType)
    symbolDescription.setType(for: node.identifier, type: functionType)
    
    _ = funEvalStack.popLast()
  }
  
  func visit(node: AstAnonymousFunctionBinding) throws {
    try visit(node: node as AstFunBinding)
  }
  
  func visit(node: AstDatatypeBinding) throws {
    let datatype = DatatypeType(parent: node.name.name, name: "")
    symbolDescription.setType(for: node, type: datatype)
    currentDatatypeName = node.name.name
    for case_ in node.cases {
      symbolDescription.setType(for: case_, type: DatatypeType(parent: node.name.name, name: case_.name.name))
    }
    currentDatatypeName = nil
  }
  
  func visit(node: AstCase) throws {
    guard let currentDatatypeName = currentDatatypeName else { throw internalError() }
    
    let datatype = DatatypeType(parent: currentDatatypeName,
                                name: node.name.name)
    
    try node.name.accept(visitor: self)
    guard let typeNode = node.associatedType else {
      let functionType = FunctionType(name: node.name.name,
                                      parameter: AbstractDummyType(name: "_"),
                                      body: datatype)
      symbolDescription.setType(for: node.name, type: functionType)
      symbolDescription.setType(for: node, type: functionType)
      return
    }
    try typeNode.accept(visitor: self)
    guard let type = symbolDescription.type(for: typeNode) else { throw internalError() }
    let functionType = FunctionType(name: node.name.name,
                                    parameter: type,
                                    body: datatype)
    symbolDescription.setType(for: node.name, type: functionType)
    symbolDescription.setType(for: node, type: functionType)
  }
  
  func visit(node: AstAtomType) throws {
    let atomType = AtomType(type: node.type)
    symbolDescription.setType(for: node, type: atomType)
  }
  
  func visit(node: AstTypeName) throws {
    func builtinType(name: String) -> AtomType? {
      return ["int": AtomType(type: .int),
              "string": AtomType(type: .string),
              "bool": AtomType(type: .bool),
              "real": AtomType(type: .real)][name]
    }
    
    if let atomType = builtinType(name: node.name) {
      symbolDescription.setType(for: node, type: atomType)
    } else {
      guard let binding = symbolTable.findBinding(name: node.name) else { throw internalError() }
      guard let type = symbolDescription.type(for: binding) else { throw internalError() }
      symbolDescription.setType(for: node, type: type)
    }
  }
  
  func visit(node: AstTupleType) throws {
    for type in node.types { try type.accept(visitor: self) }
    let types = node.types.compactMap { symbolDescription.type(for: $0) }
    let tupleType = TupleType(members: types)
    symbolDescription.setType(for: node, type: tupleType)
  }
  
  func visit(node: AstConstantExpression) throws {
    let atomType = AtomType(type: node.type)
    symbolDescription.setType(for: node, type: atomType)
  }
  
  func visit(node: AstNameExpression) throws {
    guard let binding = symbolDescription.binding(for: node) else { throw internalError() }
    guard let type = symbolDescription.type(for: binding) else { throw internalError() }
    if valBindingRhs, let type = type as? DatatypeType, !type.name.isEmpty, let _ = symbolDescription.binding(for: node) as? AstCase {
      symbolDescription.setType(for: node, type: FunctionType(name: node.name,
                                                              parameter: AbstractDummyType(name: "_"),
                                                              body: type))
    } else {
      symbolDescription.setType(for: node, type: type)
    }
  }
  
  func visit(node: AstTupleExpression) throws {
    for expression in node.expressions { try expression.accept(visitor: self) }
    let types = node.expressions.compactMap { symbolDescription.type(for: $0) }
    let tupleType = TupleType(members: types)
    symbolDescription.setType(for: node, type: tupleType)
  }
  
  func visit(node: AstBinaryExpression) throws {
    func applyType(_ resultType: Type, leftType: Type, rightType: Type) {
      symbolDescription.setType(for: node, type: resultType)
      symbolDescription.setType(for: node.right, type: rightType)
      symbolDescription.setType(for: node.left, type: leftType)
      
      if let leftBinding = symbolDescription.binding(for: node.left) {
        symbolDescription.setType(for: leftBinding, type: leftType)
      }
      
      if let rightBinding = symbolDescription.binding(for: node.right) {
        symbolDescription.setType(for: rightBinding, type: rightType)
      }
    }
    
    func concreteType(defaultType: Type, leftType: Type, rightType: Type) -> Type {
      if leftType.isAbstract && rightType.isAbstract { return defaultType }
      return leftType.isAbstract ? rightType : leftType
    }
    
    let operation = Operation.convert(node.operation)
    try node.left.accept(visitor: self)
    try node.right.accept(visitor: self)
    let leftType = symbolDescription.type(for: node.left)
    let rightType = symbolDescription.type(for: node.right)
    
    if let leftType = leftType, rightType == nil {
      let defaultType = operation.defaultType
      let operandsType = concreteType(defaultType: defaultType, leftType: leftType, rightType: leftType)
      applyType(operandsType, leftType: operandsType, rightType: operandsType)
      return
    } else if let rightType = rightType, leftType == nil {
      let defaultType = operation.defaultType
      let operandsType = concreteType(defaultType: defaultType, leftType: rightType, rightType: rightType)
      applyType(operandsType, leftType: operandsType, rightType: operandsType)
      return
    }
    
    guard leftType!.isConcrete && rightType!.isConcrete else {
      let defaultType = operation.defaultType
      let operandsType = concreteType(defaultType: defaultType, leftType: leftType!, rightType: rightType!)
      if defaultType.isBool {
        applyType(defaultType, leftType: operandsType, rightType: operandsType)
      } else {
        applyType(operandsType, leftType: operandsType, rightType: operandsType)
      }
      return
    }
    
    guard let resultType = leftType!.isBinaryOperationValid(operation, other: rightType!) else {
      throw Error.operatorError(position: node.position,
                                domain: operation.domain,
                                operand: TupleType.formPair(leftType!, rightType!))
    }
    
    applyType(resultType, leftType: leftType!, rightType: rightType!)
  }
  
  func visit(node: AstUnaryExpression) throws {
    try node.expression.accept(visitor: self)
  }
  
  func visit(node: AstIfExpression) throws {
    func applyType(_ type: Type) {
      symbolDescription.setType(for: node, type: type)
      symbolDescription.setType(for: node.trueBranch, type: type)
      symbolDescription.setType(for: node.falseBranch, type: type)
      
      if let conditionBinding = symbolDescription.binding(for: node.condition) {
        symbolDescription.setType(for: conditionBinding, type: type)
      }
      
      if let trueBranchBinding = symbolDescription.binding(for: node.trueBranch) {
        symbolDescription.setType(for: trueBranchBinding, type: type)
      }
      
      if let falseBranchBinding = symbolDescription.binding(for: node.falseBranch) {
        symbolDescription.setType(for: falseBranchBinding, type: type)
      }
    }
    
    try node.condition.accept(visitor: self)
    try node.trueBranch.accept(visitor: self)
    try node.falseBranch.accept(visitor: self)
    
    guard
      let conditionType = symbolDescription.type(for: node.condition),
      let trueBranchType = symbolDescription.type(for: node.trueBranch),
      let falseBranchType = symbolDescription.type(for: node.falseBranch) else { throw internalError() }
    
    guard conditionType.isBool else {
      throw Error.testExpressionError(position: node.condition.position, testExpressionType: conditionType)
    }
    
    guard trueBranchType.sameStructureAs(other: falseBranchType) else {
      throw Error.branchesTypeMistmatchError(position: node.position, trueBranchType: trueBranchType, falseBranchType: falseBranchType)
    }
    
    let concreteType = trueBranchType.isConcrete ? trueBranchType : falseBranchType
    applyType(concreteType)
  }
  
  func visit(node: AstLetExpression) throws {
    try node.bindings.accept(visitor: self)
    try node.expression.accept(visitor: self)
    guard let expressionType = symbolDescription.type(for: node.expression) else { throw internalError() }
    symbolDescription.setType(for: node, type: expressionType)
  }
  
  func visit(node: AstFunctionCallExpression) throws {
    if let currentFunctionBinding = funEvalStack.last, currentFunctionBinding.identifier.name == node.name {
      if let binding = symbolDescription.binding(for: node), let type = symbolDescription.type(for: binding) {
        symbolDescription.setType(for: node, type: type)
      }
      try node.argument.accept(visitor: self)
      return
    }
    
    guard let binding = symbolDescription.binding(for: node) else { throw internalError() }
    
    let rhs = valBindingRhs
    valBindingRhs = false
    try node.argument.accept(visitor: self)
    valBindingRhs = rhs
    guard let argumentType = symbolDescription.type(for: node.argument) else { throw internalError() }
    
    guard let type = symbolDescription.type(for: binding) else { throw internalError() }
    
    if let datatype = type as? DatatypeType {
      guard let case_ = binding as? AstCase else { throw internalError() }
      guard let associatedType = case_.associatedType else {
        symbolDescription.setType(for: node, type: datatype.parentDatatype)
        return
      }
      
      try associatedType.accept(visitor: self)
      guard let type = symbolDescription.type(for: associatedType) else { throw internalError() }
      guard argumentType.sameStructureAs(other: type) else {
        throw Error.operatorError(position: node.position,
                                  domain: type.description,
                                  operand: argumentType)
      }
      symbolDescription.setType(for: node, type: datatype)
      return
    }
    
    guard let functionType = type.asFunction else {
        try node.argument.accept(visitor: self)
        let abstractFunctionType = FunctionType(name: node.name,
                                                parameter: argumentType,
                                                body: AbstractDummyType(name: dummyName()))
        symbolDescription.setType(for: node, type: abstractFunctionType.body)
        symbolDescription.setType(for: binding, type: abstractFunctionType)
        return
    }
    
    guard argumentType.sameStructureAs(other: functionType.parameter) else {
      throw Error.operatorError(position: node.position,
                                domain: functionType.parameter.description,
                                operand: argumentType)
    }
    
    symbolDescription.setType(for: node.argument, type: functionType.parameter)
    symbolDescription.setType(for: node, type: functionType.body)
  }
  
  func visit(node: AstAnonymousFunctionCall) throws {
    try node.argument.accept(visitor: self)
    try node.function.accept(visitor: self)
    guard let resultType = symbolDescription.type(for: node.function) else { throw internalError() }
    symbolDescription.setType(for: node, type: resultType.asFunction?.body ?? resultType)
  }
  
  func visit(node: AstRecordExpression) throws {
    for row in node.rows { try row.accept(visitor: self) }
    let types = node.rows.compactMap { symbolDescription.type(for: $0) }
    let rows = zip(node.rows, types).map { ($0.0.label.name, $0.1) }
    let recordType = RecordType(rows: rows)
    symbolDescription.setType(for: node, type: recordType)
  }
  
  func visit(node: AstRecordRow) throws {
    try node.label.accept(visitor: self)
    try node.expression.accept(visitor: self)
    guard let type = symbolDescription.type(for: node.expression) else { throw internalError() }
    symbolDescription.setType(for: node.label, type: type)
    symbolDescription.setType(for: node, type: type)
  }
  
  func visit(node: AstRecordSelectorExpression) throws {
    try node.record.accept(visitor: self)
    guard let type = symbolDescription.type(for: node.record) else { throw internalError() }
    guard let record = type.toRecord else {
      throw Error.operatorError(position: node.record.position,
                                domain: "{\(node.label.name): 'X}; 'Z}",
                                operand: type)
    }
    let label = node.label.name
    guard let row = record.row(for: label) else {
      throw Error.operatorError(position: node.record.position,
                                domain: "{\(node.label.name): 'X}; 'Z}",
        operand: type)
    }
    symbolDescription.setType(for: node, type: row)
  }
  
  func visit(node: AstListExpression) throws {
    func areSame(types: [Type]) throws {
      guard let first = types.first else { return }
      for type in types.dropFirst() {
        guard first.sameStructureAs(other: type) else {
          throw Error.operatorError(position: node.position,
                                    domain: "[\(first.description)] * [\(first.description)] list",
                                    operand: TupleType.formPair(first, type))
        }
      }
    }
    
    for element in node.elements { try element.accept(visitor: self) }
    let types = node.elements.compactMap { symbolDescription.type(for: $0) }
    try areSame(types: types)
    let listType = ListType(elementType: types.first ?? AbstractDummyType(name: dummyName()))
    symbolDescription.setType(for: node, type: listType)
  }
  
  func visit(node: AstCaseExpression) throws {
    let parsingRhs = valBindingRhs
    valBindingRhs = false
    try node.expression.accept(visitor: self)
    valBindingRhs = parsingRhs
    try node.match.accept(visitor: self)
    
    guard let expressionType = symbolDescription.type(for: node.expression) else { throw internalError() }
    guard let matchType = symbolDescription.type(for: node.match) as? RuleType else { throw internalError() }
    guard matchType.patternType.sameStructureAs(other: expressionType) else { throw Error.operatorError(position: node.match.position,
                                                                                                        domain: expressionType.description,
                                                                                                        operand: matchType.patternType) }
    if let binding = symbolDescription.binding(for: node.expression) {
      symbolDescription.setType(for: binding, type: matchType.patternType)
    }
    symbolDescription.setType(for: node.expression, type: matchType.patternType)
    symbolDescription.setType(for: node, type: matchType.expressionType)
  }
  
  func visit(node: AstMatch) throws {
    for rule in node.rules { try rule.accept(visitor: self) }
    let types = node.rules.compactMap { symbolDescription.type(for: $0) as? RuleType }
    guard let first = types.first else { return }
    for type in types.dropFirst() {
      guard type.sameStructureAs(other: first) else {
        throw Error.operatorError(position: node.position, domain: first.description, operand: type)
      }
    }
    symbolDescription.setType(for: node, type: first)
  }
  
  func visit(node: AstRule) throws {
    let associatedValueType: Type?
    if let associatedValue = node.associatedValue {
      try node.associatedValue?.accept(visitor: self)
      associatedValueType = symbolDescription.type(for: associatedValue)
    } else {
      associatedValueType = nil
    }
    try node.pattern.accept(visitor: self)
    try node.expression.accept(visitor: self)
    guard let patternType = symbolDescription.type(for: node.pattern) else { throw internalError() }
    guard let expressionType = symbolDescription.type(for: node.expression) else { throw internalError() }
    let ruleType = RuleType(patternType: patternType, expressionType: expressionType)
    symbolDescription.setType(for: node, type: ruleType)
  }
  
  func visit(node: AstIdentifierPattern) throws {
    if let parentNodeType = typeDistributionStack.last {
      // TOOD: - Let's try to get rid of this
      symbolDescription.setType(for: node, type: parentNodeType)
      return
    }
    
    if let _ = symbolDescription.type(for: node) {
      return
    }
    
    if let binding = symbolDescription.binding(for: node), let type = symbolDescription.type(for: binding) {
      symbolDescription.setType(for: node, type: type)
      return
    }
    
    if let binding = symbolTable.findBinding(name: node.name), let type = symbolDescription.type(for: binding) {
      symbolDescription.setType(for: node, type: type)
      return
    }
    
    let dummyPatternType = AbstractDummyType(name: dummyName()) // TODO: -
    symbolDescription.setType(for: node, type: dummyPatternType)
  }
  
  func visit(node: AstWildcardPattern) throws {
    
  }
  
  func visit(node: AstTuplePattern) throws {
    if let parentNodeType = typeDistributionStack.last as? TupleType {
      symbolDescription.setType(for: node, type: parentNodeType)
      for (row, pattern) in zip(parentNodeType.rows, node.patterns) {
        typeDistributionStack.append(row.type)
        try pattern.accept(visitor: self)
        _ = typeDistributionStack.popLast()
      }
      return
    }
    let alreadyCalculatedTypes = node.patterns.compactMap { symbolDescription.type(for: $0) }
    guard alreadyCalculatedTypes.count != node.patterns.count else {
      symbolDescription.setType(for: node, type: TupleType(members: alreadyCalculatedTypes))
      return
    }
    
//    for pattern in node.patterns { try pattern.accept(visitor: self) }
//    let types = node.patterns.compactMap { symbolDescription.type(for: $0) as? AbstractType }
//    let tuplePatternType = AbstractTupleType(members: types)
//    symbolDescription.setType(for: node, type: tuplePatternType)
    
    for pattern in node.patterns { try pattern.accept(visitor: self) }
    let types = node.patterns.compactMap { symbolDescription.type(for: $0) }
    let tuple = TupleType(members: types)
    symbolDescription.setType(for: node, type: tuple)
  }
  
  func visit(node: AstRecordPattern) throws {
    
  }
  
  func visit(node: AstConstantPattern) throws {
    let atomType = AtomType.fromAtomType(node.type)
    symbolDescription.setType(for: node, type: atomType)
  }
  
  func visit(node: AstTypedPattern) throws {
    if let parentNodeType = typeDistributionStack.last {
      symbolDescription.setType(for: node, type: parentNodeType)
      try node.pattern.accept(visitor: self)
      return
    }
    
    try node.type.accept(visitor: self)
    try node.pattern.accept(visitor: self)
    
    guard
      let type = symbolDescription.type(for: node.type),
      let patternType = symbolDescription.type(for: node.pattern) else {
        throw internalError()
    }
    
    guard patternType.sameStructureAs(other: type) else {
      throw Error.constraintError(position: node.position, patternType: patternType, constraintType: type)
    }
    
    symbolDescription.setType(for: node, type: type)
    symbolDescription.setType(for: node.pattern, type: type)
  }
}

extension TypeChecker  {
  enum Error: AtherisError {
    case internalError
    case typeError(position: Position, patternType: Type, expressionType: Type)
    case constraintError(position: Position, patternType: Type, constraintType: Type)
    case operatorError(position: Position, domain: String, operand: Type)
    case testExpressionError(position: Position, testExpressionType: Type)
    case branchesTypeMistmatchError(position: Position, trueBranchType: Type, falseBranchType: Type)
    case redundantCaseError(position: Position)
    
    var errorMessage: String {
      switch self {
      case .internalError: return "internal error: \(Thread.callStackSymbols.joined(separator: "\n"))"
      case .typeError(let position, let patternType, let expressionType):
        return """
        error \(position.description): pattern and expression type do not match
        pattern: \(patternType.description)
        expression: \(expressionType.description)
        """
      case .constraintError(let position, let patternType, let constraintType):
        return """
        error \(position.description): pattern and contraint do not match
        pattern: \(patternType.description)
        constraint: \(constraintType.description)
        """
      case .operatorError(let position, let domain, let operand):
        return """
        error \(position.description): operator and operand do not match
        operator domain: \(domain)
        operand: \(operand.description)
        """
      case .testExpressionError(let position, let testExpressionType):
        return """
        error \(position.description): test expression in if is not of type bool
        test expression: \(testExpressionType.description)
        """
      case .branchesTypeMistmatchError(let position, let trueBranchType, let falseBranchType):
        return """
        error \(position.description): types of if branches do not agree
        then branch: \(trueBranchType.description)
        else branch: \(falseBranchType.description)
        """
      case .redundantCaseError(let position):
        return "error \(position.description): redundant case"
      }
    }
  }
}

private extension TypeChecker {
  func dummyName() -> String {
    let name = "'\(TypeChecker.dummyTypeCharacterSet[dummyTypeCount])"
    return name
  }
  
  func internalError() -> Error {
    return Error.internalError
  }
}
