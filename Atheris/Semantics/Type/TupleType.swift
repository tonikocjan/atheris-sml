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
    return "TupleType \(members.count): \(members.map { $0.description }.joined(separator: "; "))"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard let other = other.toTuple else { return false }
    guard other.members.count == members.count else { return false }
    return zip(members, other.members)
      .reduce(true, { (acc, tuple) in acc && tuple.0.sameStructureAs(other: tuple.1) })
  }
}
