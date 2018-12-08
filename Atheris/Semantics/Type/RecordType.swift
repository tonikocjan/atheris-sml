//
//  RecordType.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class RecordType: Type {
  typealias Rows = [(name: String, type: Type)]
  let rows: Rows
  
  init(rows: Rows) {
    self.rows = rows
  }
  
  func sameStructureAs(other: Type) -> Bool {
    guard let record = other.toRecord else {
      if rows.count == 1, let other = other.toAtom, let first = rows.first?.type {
        return first.sameStructureAs(other: other)
      }
      return false
    }
    guard record.rows.count == rows.count else { return false }
    return zip(rows, record.rows)
      .reduce(true, { (acc, tuple) in
        return acc &&
          tuple.0.type.sameStructureAs(other: tuple.1.type) &&
          tuple.0.name == tuple.1.name
      })
  }
  
  var description: String {
    return "{\(rows.map { $0.name + ":" + $0.type.description }.joined(separator: ", "))}"
  }
}

extension RecordType {
  func canBeAddedTo(other: Type) -> Bool {
    return false
  }
  
  func canBeSubtractedFrom(other: Type) -> Bool {
    return false
  }
  
  func canBeMultiplyedWith(other: Type) -> Bool {
    return false
  }
  
  func canBeDividedBy(other: Type) -> Bool {
    return false
  }
  
  func canBeConcatenatedWith(other: Type) -> Bool {
    return false
  }
  
  func canBeComparedAsEqualTo(other: Type) -> Bool {
    return self.sameStructureAs(other: other)
  }
  
  func canBeCompared(other: Type) -> Bool {
    return false
  }
  
  func canAndAlsoWith(other: Type) -> Bool {
    return false
  }
  
  func canOrElseWith(other: Type) -> Bool {
    return false
  }
}
