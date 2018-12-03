//
//  PatternTupleType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class PatternTupleType: PatternType {
  let members: [PatternType]
  
  init(members: [PatternType]) {
    self.members = members
  }
  
  var description: String {
    return "Abstract tuple type \(members.count)"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard let other = other.toTuple else { return false }
    guard members.count == other.members.count else { return false }
    
    return zip(members, other.members)
      .reduce(true, { (acc, tuple) in acc && tuple.0.sameStructureAs(other: tuple.1) })
  }
}
