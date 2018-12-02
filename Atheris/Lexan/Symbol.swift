//
//  Symbol.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//

import Foundation

struct Symbol {
  let tokenType: TokenType
  let lexeme: String
  let position: Position
}

extension Symbol: CustomStringConvertible {
  var description: String {
    return position.description + " " + tokenType.rawValue + ": " + lexeme
  }
}

struct Position {
  let startLocation: Location
  let endLocation: Location
}

extension Position {
  init(startRow: Int, startColumn: Int, endRow: Int, endColumn: Int) {
    self.startLocation = Location(row: startRow, column: startColumn)
    self.endLocation = Location(row: endRow, column: endColumn)
  }
}

extension Position: CustomStringConvertible {
  var description: String {
    return "[\(startLocation.description), \(endLocation.description)]"
  }
}

struct Location {
  let row: Int
  let column: Int
}

extension Location: CustomStringConvertible {
  var description: String {
    return "\(row):\(column)"
  }
}
