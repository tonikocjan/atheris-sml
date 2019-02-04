//
//  Symbol.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//

import Foundation

public struct Symbol {
  public let token: TokenType
  public let lexeme: String
  public let position: Position
}

extension Symbol: CustomStringConvertible {
  public var description: String {
    return position.description + " " + token.rawValue + ": " + lexeme
  }
}

public struct Position {
  public let startLocation: Location
  public let endLocation: Location
  
  public static let zero = Position(startRow: 0, startColumn: 0, endRow: 0, endColumn: 0)
}

extension Position {
  public static func + (_ lhs: Position, _ rhs: Position) -> Position {
    guard lhs != rhs else { return lhs }
    return Position(startLocation: lhs.startLocation, endLocation: rhs.endLocation)
  }
}

extension Position {
  public init(startRow: Int, startColumn: Int, endRow: Int, endColumn: Int) {
    self.startLocation = Location(row: startRow, column: startColumn)
    self.endLocation = Location(row: endRow, column: endColumn)
  }
}

extension Position: CustomStringConvertible {
  public var description: String {
    return "[\(startLocation.description), \(endLocation.description)]"
  }
}

extension Position: Hashable {
  public var hashValue: Int {
    return startLocation.hashValue ^ endLocation.hashValue
  }
  
  public static func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.startLocation == rhs.startLocation && lhs.endLocation == rhs.endLocation
  }
}

public struct Location {
  public let row: Int
  public let column: Int
}

extension Location: CustomStringConvertible {
  public var description: String {
    return "\(row):\(column)"
  }
}

extension Location: Hashable {
  public var hashValue: Int {
    return row.hashValue ^ column.hashValue
  }
  
  public static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
  }
}
