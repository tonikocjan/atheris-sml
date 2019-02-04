//
//  TupleType.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class TupleType: RecordType {
  public init(members: [Type]) {
    let rows = members.enumerated().map { ("\($0.offset + 1)", $0.element) }
    super.init(rows: rows)
  }
  
  public override var description: String {
    return "(\(rows.map { $0.type.description }.joined(separator: " * ")))"
  }
}

extension TupleType {
  public static func formPair(_ lhs: Type, _ rhs: Type) -> TupleType {
    return TupleType(members: [lhs, rhs])
  }
}
