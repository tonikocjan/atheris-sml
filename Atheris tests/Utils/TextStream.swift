//
//  TextStream.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class TextStream: InputStream {
  let string: String
  private var it = 0
  
  init(string: String) {
    self.string = string
  }
  
  func next() throws -> Character {
    guard it < string.count else { throw NSError(domain: "Empty string", code: 0, userInfo: nil) }
    it += 1
    return string[string.index(string.startIndex, offsetBy: it - 1)]
  }
}
