//
//  FunctionType.swift
//  Atheris
//
//  Created by Toni Kocjan on 05/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class FunctionType: Type {
  public let name: String
  public let parameter: Type
  public let body: Type
  
  public init(name: String, parameter: Type, body: Type) {
    self.name = name
    self.parameter = parameter
    self.body = body
  }
  
  public var description: String {
    return "fn : \(parameter.description) -> \(body.description)"
  }
  
  public var isAbstract: Bool { return false }
}

extension FunctionType {
  public func sameStructureAs(other: Type) -> Bool {
    guard let other = other.asFunction else { return false }
    return
      other.parameter.sameStructureAs(other: self.parameter) &&
      other.body.sameStructureAs(other: self.body)
  }
  
  public func canBeAddedTo(other: Type) -> Bool { return false }
  public func canBeSubtractedFrom(other: Type) -> Bool { return false }
  public func canBeMultiplyedWith(other: Type) -> Bool { return false }
  public func canBeDividedBy(other: Type) -> Bool { return false }
  public func canBeConcatenatedWith(other: Type) -> Bool { return false }
  public func canBeComparedAsEqualTo(other: Type) -> Bool { return false }
  public func canBeCompared(other: Type) -> Bool { return false }
  public func canAndAlsoWith(other: Type) -> Bool { return false }
  public func canOrElseWith(other: Type) -> Bool { return false }
}
