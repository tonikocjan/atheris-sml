//
//  PatternDummyType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class PatternDummyType: PatternType {
  var description: String {
    return "PatternDummyType"
  }
  
  func sameStructureAs(other: Type) -> Bool {
    return true
  }
}
