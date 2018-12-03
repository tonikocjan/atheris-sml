//
//  AtomType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class AtomType: Type {
  let type: AstAtomType.AtomType
  
  init(type: AstAtomType.AtomType) {
    self.type = type
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard let other = other.toAtom else { return false }
    return other.type == type
  }
  
  var description: String {
    return type.rawValue
  }
}
