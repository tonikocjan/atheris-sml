//
//  LexAn.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class LexAn: LexicalAnalyzer {
  let fileURL: URL
  
  init(parseFile path: String) throws {
    guard let url = URL(string: path) else { throw Error.invalidPath }
    self.fileURL = url
  }
  
  func nextSymbol() -> Symbol {
    return Symbol(tokenType: .identifier,
                  lexeme: "test",
                  position: Position(startRow: 0,
                                     startColumn: 0,
                                     endRow: 0,
                                     endColumn: 5))
  }
}

extension LexAn {
  enum Error: Swift.Error {
    case invalidPath
  }
}
