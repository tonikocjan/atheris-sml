//
//  AtomType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AtomType: Type {
  public let type: AstAtomType.AtomType
  
  public init(type: AstAtomType.AtomType) {
    self.type = type
  }
  
  public func sameStructureAs(other: Type) -> Bool {
    guard !other.isAbstract else { return true }
    guard !other.isPolymorphic else { return true }
    guard let other = other.toAtom else { return false }
    return other.type == type
  }
  
  public var description: String {
    return type.rawValue
  }
  
  public var isAbstract: Bool { return false }
}

extension AtomType {
  public func canBeAddedTo(other: Type) -> Bool {
    return other.isAbstract || self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  public func canBeSubtractedFrom(other: Type) -> Bool {
    return other.isAbstract || self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  public func canBeMultiplyedWith(other: Type) -> Bool {
    return other.isAbstract || self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  public func canBeDividedBy(other: Type) -> Bool {
    return other.isAbstract || self.isReal && other.isReal
  }
  
  public func canBeConcatenatedWith(other: Type) -> Bool {
    return other.isAbstract || self.isString && other.isString
  }
  
  public func canBeComparedAsEqualTo(other: Type) -> Bool {
    return
      other.isAbstract ||
      self.isInt && other.isInt ||
      self.isString && other.isString  ||
      self.isBool && other.isBool
  }
  
  public func canBeCompared(other: Type) -> Bool {
    return other.isAbstract || self.isInt && other.isInt || self.isReal && other.isReal
  }
  
  public func canAndAlsoWith(other: Type) -> Bool {
    return other.isAbstract || self.isBool && other.isBool
  }
  
  public func canOrElseWith(other: Type) -> Bool {
    return other.isAbstract || self.isBool && other.isBool
  }
}

extension AtomType {
  public static let int = AtomType(type: .int)
  public static let string = AtomType(type: .string)
  public static let real = AtomType(type: .real)
  public static let bool = AtomType(type: .bool)
  public static func fromAtomType(_ atomType: AstAtomType.AtomType) -> AtomType {
    switch atomType {
    case .int: return int
    case .real: return real
    case .string: return string
    case .bool: return bool
    }
  }
}
