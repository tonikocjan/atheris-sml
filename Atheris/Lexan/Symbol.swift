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
    return tokenType.rawValue + ": " + lexeme + "[\(position.startLocation.description) - \(position.endLocation.description)]"
  }
}

//extension Symbol {
//  class Builder {
//    private let tokenType: TokenType?
//    private let lexeme: String?
//    private let startLocation: Location?
//    private let endLocation: Location?
//
//    func build() -> Symbol {
//      return Symbol(tokenType: tokenType,
//                    lexeme: lexeme,
//                    position: Position(startLocation: startLocation,
//                                       endLocation: endLocation))
//    }
//  }
//}

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

struct Location {
  let row: Int
  let column: Int
}

extension Location: CustomStringConvertible {
  var description: String {
    return "\(row):\(column)"
  }
}
