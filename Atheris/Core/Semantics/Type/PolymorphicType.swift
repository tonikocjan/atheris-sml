//
//  PolymorphicType.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class PolymorphicType: Type {
  let name: String
  let type: AstTypeBinding.Kind
  
  var description: String {
    return name
  }
  
  var isAbstract: Bool {
    return false
  }
  
  init(binding: AstTypeBinding) { // TODO: - Shouldnt be aware of `asttypebinding`
    self.name = binding.name
    self.type = binding.type
  }
  
  init(name: String, type: AstTypeBinding.Kind) {
    self.name = name
    self.type = type
  }
  
  func sameStructureAs(other: Type) -> Bool {
//    guard let other = other as? PolymorphicType else { return false }
//    return other.description == description
    return canAccept(type: other)
  }
  
  func canAccept(type: Type) -> Bool {
    switch self.type {
    case .normal:
      return true
    case .equatable:
      if type.isAtom { return true }
      return true
      // TODO: - Which types cannot be equatable?
    }
  }
}

extension PolymorphicType {
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
