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
  let constructorTypes: [Type]
  let associatedType: Type?
  
  init(parent: String, name: String, constructorTypes: [Type]) {
    self.parent = parent
    self.name = name
    self.constructorTypes = constructorTypes
    self.associatedType = nil
  }
  
  init(parent: String, name: String, constructorTypes: [Type], associatedType: Type?) {
    self.parent = parent
    self.name = name
    self.constructorTypes = constructorTypes
    self.associatedType = associatedType
  }
  
  var description: String {
    return "[\(parent) => \(name)]"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    if other.isAbstract { return true }
    guard let datatype = other as? DatatypeType else { return false }
    return datatype.parent == self.parent
  }
  
  var parentDatatype: DatatypeType {
    return DatatypeType(parent: self.parent,
                        name: "",
                        constructorTypes: constructorTypes)
  }
  
  var isAbstract: Bool { return false }
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
