//
//  PatternDummyType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class PatternDummyType: PatternType {
  let name: String
  
  init(name: String) {
    self.name = name
  }
  
  var description: String {
    return name
  }
  
  func sameStructureAs(other: Type) -> Bool {
    return true
  }
}
