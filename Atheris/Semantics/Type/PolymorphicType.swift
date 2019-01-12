//
//  PolymorphicType.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class PolymorphicType: Type {
  let binding: AstTypeBinding
  
  var description: String {
    return binding.name
  }
  
  var isAbstract: Bool {
    return false
  }
  
  init(binding: AstTypeBinding) {
    self.binding = binding
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard let other = other as? PolymorphicType else { return false }
    return other.description == description
  }
  
  func canAccept(type: Type) -> Bool {
    switch binding.type {
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
