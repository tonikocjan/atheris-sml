//
//  RuleType.swift
//  Atheris
//
//  Created by Toni Kocjan on 14/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class RuleType: Type {
  let patternType: Type
  let expressionType: Type
  
  init(patternType: Type, expressionType: Type) {
    self.patternType = patternType
    self.expressionType = expressionType
  }
  
  var description: String {
    return "\(patternType.description) => \(expressionType.description)"
  }
  
  var isAbstract: Bool { return false }
}

extension RuleType {
  func sameStructureAs(other: Type) -> Bool {
    guard let rule = (other as? RuleType) else { return false }
    return
      rule.expressionType.sameStructureAs(other: self.expressionType) &&
      rule.patternType.sameStructureAs(other: self.patternType)
  }
  
  func canBeAddedTo(other: Type) -> Bool { return false }
  func canBeSubtractedFrom(other: Type) -> Bool { return false }
  func canBeMultiplyedWith(other: Type) -> Bool { return false }
  func canBeDividedBy(other: Type) -> Bool { return false }
  func canBeConcatenatedWith(other: Type) -> Bool { return false }
  func canBeComparedAsEqualTo(other: Type) -> Bool { return false }
  func canBeCompared(other: Type) -> Bool { return false }
  func canAndAlsoWith(other: Type) -> Bool { return false }
  func canOrElseWith(other: Type) -> Bool { return false }
  
  func isBinaryOperationValid(_ operation: Operation, other: Type) -> Type? { return nil }
}
