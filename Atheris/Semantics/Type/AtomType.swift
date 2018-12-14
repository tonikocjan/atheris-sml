//
//  AtomType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AtomType: Type {
  let type: AstAtomType.AtomType
  
  init(type: AstAtomType.AtomType) {
    self.type = type
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard !other.isAbstract else { return true }
    guard let other = other.toAtom else { return false }
    return other.type == type
  }
  
  var description: String {
    return type.rawValue
  }
}

extension AtomType {
  func canBeAddedTo(other: Type) -> Bool {
    return other.isAbstract || self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  func canBeSubtractedFrom(other: Type) -> Bool {
    return other.isAbstract || self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  func canBeMultiplyedWith(other: Type) -> Bool {
    return other.isAbstract || self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  func canBeDividedBy(other: Type) -> Bool {
    return other.isAbstract || self.isReal && other.isReal
  }
  
  func canBeConcatenatedWith(other: Type) -> Bool {
    return other.isAbstract || self.isString && other.isString
  }
  
  func canBeComparedAsEqualTo(other: Type) -> Bool {
    return
      other.isAbstract ||
      self.isInt && other.isInt ||
      self.isString && other.isString  ||
      self.isBool && other.isBool
  }
  
  func canBeCompared(other: Type) -> Bool {
    return other.isAbstract || self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  func canAndAlsoWith(other: Type) -> Bool {
    return other.isAbstract || self.isBool && other.isBool
  }
  
  func canOrElseWith(other: Type) -> Bool {
    return other.isAbstract || self.isBool && other.isBool
  }
}

extension AtomType {
  static let int = AtomType(type: .int)
  static let string = AtomType(type: .string)
  static let real = AtomType(type: .real)
  static let bool = AtomType(type: .bool)
  static func fromAtomType(_ atomType: AstAtomType.AtomType) -> AtomType {
    switch atomType {
    case .int: return int
    case .real: return real
    case .string: return string
    case .bool: return bool
    }
  }
}
