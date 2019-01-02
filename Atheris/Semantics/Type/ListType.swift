//
//  ListType.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class ListType: Type {
  let type: Type
  
  init(elementType type: Type) {
    self.type = type
  }
  
  var description: String {
    return "\(type.description) list"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    if other.isAbstract { return true }
    guard let list = other.toList else { return false }
    return list.type.sameStructureAs(other: type)
  }
  
  var isAbstract: Bool { return false }
}

extension ListType {
  func canBeAddedTo(other: Type) -> Bool { return false }
  func canBeSubtractedFrom(other: Type) -> Bool { return false }
  func canBeMultiplyedWith(other: Type) -> Bool { return false }
  func canBeDividedBy(other: Type) -> Bool { return false }
  func canBeConcatenatedWith(other: Type) -> Bool { return false }
  func canBeComparedAsEqualTo(other: Type) -> Bool { return false }
  func canBeCompared(other: Type) -> Bool { return false }
  func canAndAlsoWith(other: Type) -> Bool { return false }
  func canOrElseWith(other: Type) -> Bool { return false }
}
