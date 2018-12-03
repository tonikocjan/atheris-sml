//
//  Type.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol Type: class, CustomStringConvertible {
  func sameStructureAs(other: Type) -> Bool
}

extension Type {
  var isAtom: Bool { return self is AtomType }
  var toAtom: AtomType? { return self as? AtomType}
}

extension Type {
  var isTuple: Bool { return self is TupleType }
  var toTuple: TupleType? { return self as? TupleType}
}
