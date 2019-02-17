//
//  ListType.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class ListType: Type {
  public let type: Type
  
  public init(elementType type: Type) {
    self.type = type
  }
  
  public var description: String {
    return "\(type.description) list"
  }
  
  public func sameStructureAs(other: Type) -> Bool {
    if other.isAbstract { return true }
    guard let list = other.toList else { return false }
    return list.type.sameStructureAs(other: type)
  }
  
  public var isAbstract: Bool { return false }
}

extension ListType {
  public func canBeAddedTo(other: Type) -> Bool { return false }
  public func canBeSubtractedFrom(other: Type) -> Bool { return false }
  public func canBeMultiplyedWith(other: Type) -> Bool { return false }
  public func canBeDividedBy(other: Type) -> Bool { return false }
  public func canBeConcatenatedWith(other: Type) -> Bool { return false }
  public func canBeComparedAsEqualTo(other: Type) -> Bool { return false }
  public func canBeCompared(other: Type) -> Bool { return false }
  public func canAndAlsoWith(other: Type) -> Bool { return false }
  public func canOrElseWith(other: Type) -> Bool { return false }
}
