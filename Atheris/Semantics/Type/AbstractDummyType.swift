//
//  PatternDummyType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AbstractDummyType: AbstractType {
  let name: String
  
  init(name: String) {
    self.name = name
  }
  
  var description: String {
    return name
  }
  
  func sameStructureAs(other: Type) -> Bool {
    return true
  }
  
  var isAbstract: Bool { return true }
}

extension AbstractDummyType {
  func canBeAddedTo(other: Type) -> Bool { return other.isConcrete && other.canBeAddedTo(other: other) }
  func canBeSubtractedFrom(other: Type) -> Bool { return other.isConcrete && other.canBeSubtractedFrom(other: other) }
  func canBeMultiplyedWith(other: Type) -> Bool { return other.isConcrete && other.canBeMultiplyedWith(other: other) }
  func canBeDividedBy(other: Type) -> Bool { return other.isConcrete && other.canBeDividedBy(other: other) }
  func canBeConcatenatedWith(other: Type) -> Bool { return other.isConcrete && other.canBeConcatenatedWith(other: other) }
  func canBeComparedAsEqualTo(other: Type) -> Bool { return other.isConcrete && other.canBeComparedAsEqualTo(other: other) }
  func canBeCompared(other: Type) -> Bool { return other.isConcrete && other.canBeCompared(other: other) }
  func canAndAlsoWith(other: Type) -> Bool { return other.isConcrete && other.canAndAlsoWith(other: other) }
  func canOrElseWith(other: Type) -> Bool { return other.isConcrete && other.canOrElseWith(other: other) }
}
