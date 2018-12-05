//
//  Type.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

enum Operation: String {
  case add = "+"
  case subtract = "-"
  case multiply = "*"
  case divide = "/"
  case concat = "^"
  case lessThan = "<"
  case greaterThan = ">"
  case equal = "="
  case lessThanOrEqual = "<="
  case greaterThanOrEqual = ">="
  case andalso = "andalso"
  case orelse = "orelse"
  case unknown

  var domain: String {
    if self == .andalso || self == .orelse { return "bool * bool" }
    return "[\(rawValue) ty] * [\(rawValue) ty]"
  }
  
  static func convert(_ op: AstBinaryExpression.Operation) -> Operation {
    return Operation.init(rawValue: op.rawValue) ?? .unknown
  }
}

protocol Type: class, CustomStringConvertible {
  func sameStructureAs(other: Type) -> Bool
  
  func canBeAddedTo(other: Type) -> Bool
  func canBeSubtractedFrom(other: Type) -> Bool
  func canBeMultiplyedWith(other: Type) -> Bool
  func canBeDividedBy(other: Type) -> Bool
  func canBeConcatenatedWith(other: Type) -> Bool
  func canBeComparedAsEqualTo(other: Type) -> Bool
  func canBeCompared(other: Type) -> Bool
  func canAndAlsoWith(other: Type) -> Bool
  func canOrElseWith(other: Type) -> Bool
  
  func isBinaryOperationValid(_ operation: Operation, other: Type) -> Type?
}

extension Type {
  var isAtom: Bool { return self is AtomType }
  var toAtom: AtomType? { return self as? AtomType}
  
  var isBool: Bool { return (toAtom?.type ?? .int) == .bool }
  var isReal: Bool { return (toAtom?.type ?? .int) == .real }
  var isInt: Bool { return (toAtom?.type ?? .string) == .int }
  var isString: Bool { return (toAtom?.type ?? .int) == .string }
}

extension Type {
  var isTuple: Bool { return self is TupleType }
  var toTuple: TupleType? { return self as? TupleType}
}

extension Type {
  func isBinaryOperationValid(_ operation: Operation, other: Type) -> Type? {
    switch operation {
    case .add:
      return self.canBeAddedTo(other: other) ? self : nil
    case .subtract:
      return self.canBeSubtractedFrom(other: other) ? self : nil
    case .multiply:
      return self.canBeMultiplyedWith(other: other) ? self : nil
    case .divide:
      return self.canBeDividedBy(other: other) ? self : nil
    case .concat:
      return self.canBeConcatenatedWith(other: other) ? self : nil
    case .lessThan,
         .greaterThan,
         .lessThanOrEqual,
         .greaterThanOrEqual:
      return self.canBeCompared(other: other) ? AtomType.boolType : nil
    case .equal:
      return self.canBeComparedAsEqualTo(other: other) ? AtomType.boolType : nil
    case .andalso:
      return self.canAndAlsoWith(other: other) ? AtomType.boolType : nil
    case .orelse:
      return self.canOrElseWith(other: other) ? AtomType.boolType : nil
    case .unknown:
      return nil
    }
  }
}
