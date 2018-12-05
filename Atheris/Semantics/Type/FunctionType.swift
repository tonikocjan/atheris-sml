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
  let parameters: [TupleType]
  let body: Type
  
  init(name: String, parameters: [TupleType], body: Type) {
    self.name = name
    self.parameters = parameters
    self.body = body
  }
  
  var description: String {
    return "fn : \(parameters.description) -> \(body.description)"
  }
}

extension FunctionType {
  func sameStructureAs(other: Type) -> Bool {
    guard let other = other.asFunction else { return false }
    return zip(self.parameters, other.parameters)
      .reduce(true, { (acc, tuple) in acc && tuple.0.sameStructureAs(other: tuple.1) })
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
