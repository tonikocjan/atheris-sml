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
    let code = """
val (x, (a, b)): int = (10, (20, 30));
"""
    performFailingTest(code: code)
  }
  
  func testIfBranchesTypeMistmatch() {
    let code = """
val x = if true then 10 else false;
"""
    performFailingTest(code: code)
  }
  
  func testIfConditionNotBool() {
    let code = """
val x = if 10 * 10 then "a" else "b";
"""
    performFailingTest(code: code)
  }
  
  func testIfBranchesTypeMismatchWithInference() {
    let code = """
fun pow (x: real, y) =
  if y = 0 then 1
  else x * pow (x, y - 1);
"""
    performFailingTest(code: code)
  }
}

private extension TypeCheckerTests {
  func performFailingTest(code: String) {
    do {
      let lexan = LexAn(inputStream: TextStream(string: code))
      let parser = SynAn(lexan: lexan)
      let ast = try parser.parse()
      let symbolTable = SymbolTable(symbolDescription: SymbolDescription())
      let nameChecker = NameChecker(symbolTable: symbolTable, symbolDescription: symbolTable.symbolDescription)
      try nameChecker.visit(node: ast)
      let typeChecker = TypeChecker(symbolTable: symbolTable, symbolDescription: symbolTable.symbolDescription)
      try typeChecker.visit(node: ast)
    } catch {
      guard let _ = error as? TypeChecker.Error else {
        XCTFail()
        return
      }
    }
  }
}
