//
//  CaseType.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class CaseType: Type {
  let name: String
  
  init(name: String) {
    self.name = name
  }
  
  var description: String {
    return name
  }
  
  func sameStructureAs(other: Type) -> Bool {
    return false
  }
}

extension CaseType {
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
