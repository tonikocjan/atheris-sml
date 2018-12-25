//
//  PatternTupleType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AbstractTupleType: AbstractType {
  let members: [AbstractType]
  
  init(members: [AbstractType]) {
    self.members = members
  }
  
  var description: String {
    return "(\(members.map { $0.description }.joined(separator: " * ")))"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard let other = other.toTuple else { return false }
    guard members.count == other.rows.count else { return false }
    
    return zip(members, other.rows)
      .reduce(true, { (acc, tuple) in acc && tuple.0.sameStructureAs(other: tuple.1.type) })
  }
  
  var isAbstract: Bool { return true }
}

extension AbstractTupleType {
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
