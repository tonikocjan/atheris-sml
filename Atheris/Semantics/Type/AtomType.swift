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
    guard let other = other.toAtom else { return false }
    return other.type == type
  }
  
  var description: String {
    return type.rawValue
  }
}

extension AtomType {
  func canBeAddedTo(other: Type) -> Bool {
    return self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  func canBeSubtractedFrom(other: Type) -> Bool {
    return self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  func canBeMultiplyedWith(other: Type) -> Bool {
    return self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  func canBeDividedBy(other: Type) -> Bool {
    return self.isReal && other.isReal
  }
  
  func canBeComparedAsEqualTo(other: Type) -> Bool {
    return
      self.isInt && other.isInt ||
      self.isString && other.isString  ||
      self.isBool && other.isBool
  }
  
  func canBeCompared(other: Type) -> Bool {
    return self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  func canAndAlsoWith(other: Type) -> Bool {
    return self.isBool && other.isBool
  }
  
  func canOrElseWith(other: Type) -> Bool {
    return self.isBool && other.isBool
  }
}

extension AtomType {
  static let intType = AtomType(type: .int)
  static let stringType = AtomType(type: .string)
  static let realType = AtomType(type: .real)
  static let boolType = AtomType(type: .bool)
}
