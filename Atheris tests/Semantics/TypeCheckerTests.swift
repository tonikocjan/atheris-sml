//
//  TypeCheckerTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import XCTest

class TypeCheckerTests: XCTestCase {
  func testSimplePatternMatchingShouldFail() {
    do {
      let code = "val (x, (a, b)): int = (10, (20, 30));"
      let lexan = LexAn(inputStream: TextStream(string: code))
      let parser = SynAn(lexan: lexan)
      let ast = try parser.parse()
      let symbolTable = SymbolTable(symbolDescription: SymbolDescription())
      let nameChecker = NameChecker(symbolTable: symbolTable, symbolDescription: symbolTable.symbolDescription)
      try nameChecker.visit(node: ast)
      let typeChecker = TypeChecker(symbolTable: symbolTable, symbolDescription: symbolTable.symbolDescription)
      try typeChecker.visit(node: ast)
    } catch {
      guard let error = error as? TypeChecker.Error else {
        XCTFail()
        return
      }
      
      switch error {
      case .constraintError(_, let patternType, let constraintType):
        guard patternType is PatternTupleType && constraintType.isAtom else {
          XCTFail()
          return
        }
      default:
        XCTFail()
      }
    }
  }
}
