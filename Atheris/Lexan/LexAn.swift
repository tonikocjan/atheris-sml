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
  let fileHandle: FileHandle
  
  init(parseFile path: String) throws {
    guard let url = URL(string: path) else { throw Error.invalidPath(path) }
    self.fileURL = url
    guard let fileHandle = try? FileHandle(forReadingFrom: url) else { throw Error.fileNotFound(fileURL) }
    self.fileHandle = fileHandle
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
    case invalidPath(String)
    case fileNotFound(URL)
    
    var localizedDescription: String {
      switch self {
      case .invalidPath(let url):
        return "\(url) is not a valid URL!"
      case .fileNotFound:
        return "File not found or cannot be opened!"
      }
    }
  }
}
