//
//  UnitType.swift
//  Atheris
//
//  Created by Toni Kocjan on 29/12/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class UnitType: Type {
  func sameStructureAs(other: Type) -> Bool {
    other is UnitType
  }
  
  func canBeAddedTo(other: Type) -> Bool {
    false
  }
  
  func canBeSubtractedFrom(other: Type) -> Bool {
    false
  }
  
  func canBeMultiplyedWith(other: Type) -> Bool {
    false
  }
  
  func canBeDividedBy(other: Type) -> Bool {
    false
  }
  
  func canBeConcatenatedWith(other: Type) -> Bool {
    false
  }
  
  func canBeComparedAsEqualTo(other: Type) -> Bool {
    other is UnitType
  }
  
  func canBeCompared(other: Type) -> Bool {
    other is UnitType
  }
  
  func canAndAlsoWith(other: Type) -> Bool {
    false
  }
  
  func canOrElseWith(other: Type) -> Bool {
    false
  }
  
  var isAbstract: Bool { false }
  
  var description: String { "Unit" }
}
