//
//  Τree.swift
//  Atheris
//
//  Created by Toni Kocjan on 26/12/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

public extension λcalculusGenerator {
  indirect enum Tree {
    case variable(name: String)
    case abstraction(variable: String, expression: Tree)
    case application(fn: Tree, value: Tree)
    case constant(value: Int)
    case binding(v: String, expression: Tree)
    case bindings([(v: String, expression: Tree)])
  }
}

extension λcalculusGenerator.Tree: CustomStringConvertible {
  public var description: String {
    func stringRepresentation(_ tree: λcalculusGenerator.Tree) -> String {
      switch tree {
      case .variable(let name):
        return name
      case .application(let fn, let value):
        return "(" + stringRepresentation(fn) + "" + stringRepresentation(value) + ")"
      case .abstraction(let variable, let expr):
        return "(\\" + variable + "." + stringRepresentation(expr) + ")"
      case .constant(let value):
        return String(value)
      case .binding(let variable, let expression):
        return "let " + variable + " = " + stringRepresentation(expression)
      case .bindings(let bindings):
        return bindings
          .map { "let " + $0.v + " = " + stringRepresentation($0.expression) }
          .joined(separator: "\n")
      }
    }
    
    return stringRepresentation(self)
  }
}

extension λcalculusGenerator.Tree: Equatable {
  public static func == (lhs: λcalculusGenerator.Tree, rhs: λcalculusGenerator.Tree) -> Bool {
    switch (lhs, rhs) {
    case (.variable(let v1), .variable(let v2)):
      return v1 == v2
    case (.application(let f1, let e1), .application(let f2, let e2)):
      return f1 == f2 && e1 == e2
    case (.abstraction(let v1, let e1), .abstraction(let v2, let e2)):
      return v1 == v2 && e1 == e2
    case _:
      return false
    }
  }
}
