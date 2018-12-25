//
//  FunctionType.swift
//  Atheris
//
//  Created by Toni Kocjan on 05/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class FunctionType: Type {
  let name: String
  let parameter: Type
  let body: Type
  
  init(name: String, parameter: Type, body: Type) {
    self.name = name
    self.parameter = parameter
    self.body = body
  }
  
  var description: String {
    return "fn : \(parameter.description) -> \(body.description)"
  }
  
  var isAbstract: Bool { return false }
}

extension FunctionType {
  func sameStructureAs(other: Type) -> Bool {
    guard let other = other.asFunction else { return false }
    return
      other.parameter.sameStructureAs(other: self.parameter) &&
      other.body.sameStructureAs(other: self.body)
  }
  
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
