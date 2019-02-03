//
//  DataType.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class DataType: Type {
  let name: String
  let constructorTypes: [(name: String, type: Type)]
  let cases: [String: Type]
  
  init(name: String, constructorTypes: [(String, Type)], cases: [String: Type]) {
    self.name = name
    self.constructorTypes = constructorTypes
    self.cases = cases
  }
  
  var description: String {
    if constructorTypes.isEmpty { return name }
    let constructors = constructorTypes
      .map { $0.1.description }
      .joined(separator: ", ")
    return "(\(constructors)) \(name)"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    if other.isAbstract { return true }
    if let dataType = other as? DataType { return dataType.name == name }
    guard let caseType = other as? CaseType else { return false }
    guard caseType.parent.name == self.name else { return false }
    guard let selectedCase = cases[caseType.name] else { return true }
    guard let associatedType = caseType.associatedType else { return false }
    return selectedCase.sameStructureAs(other: associatedType)
  }
}

extension DataType {
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
