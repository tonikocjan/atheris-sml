//
//  Symbol.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//

import Foundation

struct Symbol {
  let token: TokenType
  let lexeme: String
  let position: Position
}

extension Symbol: CustomStringConvertible {
  var description: String {
    return position.description + " " + token.rawValue + ": " + lexeme
  }
}

struct Position {
  let startLocation: Location
  let endLocation: Location
  
  static let zero = Position(startRow: 0, startColumn: 0, endRow: 0, endColumn: 0)
}

extension Position {
  static func + (_ lhs: Position, _ rhs: Position) -> Position {
    guard lhs != rhs else { return lhs }
    return Position(startLocation: lhs.startLocation, endLocation: rhs.endLocation)
  }
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

extension Position: Hashable {
  var hashValue: Int {
    return startLocation.hashValue ^ endLocation.hashValue
  }
  
  static func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.startLocation == rhs.startLocation && lhs.endLocation == rhs.endLocation
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

extension Location: Hashable {
  var hashValue: Int {
    return row.hashValue ^ column.hashValue
  }
  
  static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
  }
}
