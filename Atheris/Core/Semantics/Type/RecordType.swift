//
//  RecordType.swift
//  Atheris
//
//  Created by Toni Kocjan on 08/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class RecordType: Type {
  public typealias Rows = [(name: String, type: Type)]
  public let rows: Rows
  
  public init(rows: Rows) {
    self.rows = rows
  }

  public func row(for name: String) -> Type? {
    return rows.first(where: { $0.name == name })?.type
  }
  
  public var description: String {
    return "{\(rows.map { $0.name + ":" + $0.type.description }.joined(separator: ", "))}"
  }
  
  public func sameStructureAs(other: Type) -> Bool {
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
  
  public var isAbstract: Bool {
    for row in rows {
      if row.type.isAbstract { return true }
    }
    return false
  }
}

extension RecordType {
  public func canBeAddedTo(other: Type) -> Bool {
    return false
  }
  
  public func canBeSubtractedFrom(other: Type) -> Bool {
    return false
  }
  
  public func canBeMultiplyedWith(other: Type) -> Bool {
    return false
  }
  
  public func canBeDividedBy(other: Type) -> Bool {
    return false
  }
  
  public func canBeConcatenatedWith(other: Type) -> Bool {
    return false
  }
  
  public func canBeComparedAsEqualTo(other: Type) -> Bool {
    return self.sameStructureAs(other: other)
  }
  
  public func canBeCompared(other: Type) -> Bool {
    return false
  }
  
  public func canAndAlsoWith(other: Type) -> Bool {
    return false
  }
  
  public func canOrElseWith(other: Type) -> Bool {
    return false
  }
}
