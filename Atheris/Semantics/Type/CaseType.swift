//
//  CaseType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/02/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class CaseType: Type {
  let parent: DataType
  let name: String
  let associatedType: Type?
  
  init(parent: DataType, name: String, associatedType: Type?) {
    self.parent = parent
    self.name = name
    self.associatedType = associatedType
  }
  
  var description: String {
    switch associatedType {
    case .some(let type):
      return "(\(type.description)) \(parent.description)"
    case .none:
      return parent.description
    }
  }
  
  func sameStructureAs(other: Type) -> Bool {
    if other.isAbstract { return true }
    if let dataType = other as? DataType { return dataType.name == parent.name }
    guard let caseType = other as? CaseType else { return false }
    return self.parent.name == caseType.parent.name
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
  var isAbstract: Bool { return false }
}
