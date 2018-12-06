//
//  TupleType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class TupleType: Type {
  let members: [Type]
  
  init(members: [Type]) {
    self.members = members
  }
  
  var description: String {
    return "(\(members.map { $0.description }.joined(separator: " * ")))"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard let tuple = other.toTuple else {
      if members.count == 1, let other = other.toAtom, let first = members.first {
        return first.sameStructureAs(other: other)
      }
      return false
    }
    guard tuple.members.count == members.count else { return false }
    return zip(members, tuple.members)
      .reduce(true, { (acc, tuple) in acc && tuple.0.sameStructureAs(other: tuple.1) })
  }
}

extension TupleType {
  static func formPair(_ lhs: Type, _ rhs: Type) -> TupleType {
    return TupleType(members: [lhs, rhs])
  }
}

extension TupleType {
  func canBeAddedTo(other: Type) -> Bool {
    return false
  }
  
  func canBeSubtractedFrom(other: Type) -> Bool {
    return false
  }
  
  func canBeMultiplyedWith(other: Type) -> Bool {
    return false
  }
  
  func canBeDividedBy(other: Type) -> Bool {
    return false
  }
  
  func canBeConcatenatedWith(other: Type) -> Bool {
    return false
  }
  
  func canBeComparedAsEqualTo(other: Type) -> Bool {
    return self.sameStructureAs(other: other)
  }
  
  func canBeCompared(other: Type) -> Bool {
    return false
  }
  
  func canAndAlsoWith(other: Type) -> Bool {
    return false
  }
  
  func canOrElseWith(other: Type) -> Bool {
    return false
  }
}
