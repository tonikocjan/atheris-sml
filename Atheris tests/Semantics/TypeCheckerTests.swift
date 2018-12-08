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
  
  func testAnonymousFunctionOperationNotSupported() {
    let code = """
val x = fn x => fn y => fn z => z (x, y);
val z = x ("abc") ("efg") (fn (x, y) => x + y);
"""
    performFailingTest(code: code)
  }
  
  func testRecordComparisonShouldFail() {
    let code = """
val x = {1 = 10, 3 = 20};
val y = {1 = 10, 2 = 20};
val c = x = y;
"""
    performFailingTest(code: code)
  }
  
  func testRecordTupleComparisonShouldFail() {
    let code = """
val x = (10, 20);
val y = {1 = 10, 3 = 20};
val c = x = y;
"""
    performFailingTest(code: code)
  }
  
  func tesRecordComparisonShouldSucceed() {
    let code = """
val x = (10, 20);
val y = {1 = 10, 2 = 20};
val z = {1 = 55, 2 = 30};
val c = x = y andalso y == z;
"""
    performSucceedingTest(code: code)
  }
  
  func testRecordSelectorShouldSucceed() {
    let code = """
val x = (10, 20);
val y = {1 = 10, 2 = 20};
val z = {1 = 55, 2 = 30};
val a = #1 y;
val b = #2 z;
val c = #1 x;
val d = #2 x;
"""
    performSucceedingTest(code: code)
  }
  
  func testRecordSelectorShouldFailNotPresent() {
    let code = """
val y = {1 = 10, 2 = 20};
val a = #a y;
"""
    performFailingTest(code: code)
  }
  
  func testRecordSelectorShouldFailNotRecord() {
    let code = """
val y = "abc";
val a = #a y;
"""
    performFailingTest(code: code)
  }
}

private extension TypeCheckerTests {
  func performFailingTest(code: String) {
    performTest(code: code, shouldSucceed: false)
  }
  
  func performSucceedingTest(code: String) {
    performTest(code: code, shouldSucceed: true)
  }
  
  func performTest(code: String, shouldSucceed: Bool) {
    do {
      let lexan = LexAn(inputStream: TextStream(string: code))
      let parser = SynAn(lexan: lexan)
      let ast = try parser.parse()
      let symbolTable = SymbolTable(symbolDescription: SymbolDescription())
      let nameChecker = NameChecker(symbolTable: symbolTable, symbolDescription: symbolTable.symbolDescription)
      try nameChecker.visit(node: ast)
      let typeChecker = TypeChecker(symbolTable: symbolTable, symbolDescription: symbolTable.symbolDescription)
      try typeChecker.visit(node: ast)
      if !shouldSucceed { XCTFail() }
    } catch {
      guard !shouldSucceed else { return XCTFail() }
      guard let _ = error as? TypeChecker.Error else {
        XCTFail()
        return
      }
    }
  }
}
