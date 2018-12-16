//
//  DatatypeType.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class DatatypeType: Type {
  let parent: String
  let name: String
  
  init(parent: String, name: String) {
    self.parent = parent
    self.name = name
  }
  
  var description: String {
    return "[\(parent) => \(name)]"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard let datatype = other as? DatatypeType else { return false }
    return datatype.parent == self.parent
  }
}

extension DatatypeType {
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
