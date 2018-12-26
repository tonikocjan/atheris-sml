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
  
  func testListExpressionNotSameTypesShouldFail() {
    let code = """
val x = [1, 2, true];
"""
    performFailingTest(code: code)
  }
  
  func testDatatypeConstructorArgumentInvalid() {
    let code = """
datatype prevozno_sredstvo_t =
  Bus of int
  | Avto of (string*string*int)
  | Pes;

val x = Bus (10, 20);
val y = Avto ("abc", "efg", 10);
val z = Pes;
"""
    performFailingTest(code: code)
  }
  
  func testCaseExpressionInvalidResultType() {
    let code = """
val x = true;
val y = case x of
  true => true
  | false => 2;
"""
    performFailingTest(code: code)
  }
  
  func testCaseExpressionInvalidPatternType() {
    let code = """
val x = true;
val y = case x of
  true => 1
  | 3 => 2;
"""
    performFailingTest(code: code)
  }
  
  func testCaseExpressionInvalidExpressionType() {
    let code = """
val x = true;
val y = case x of
  10 => 1
  | 20 => 2;
"""
    performFailingTest(code: code)
  }
  
  func testFunBindingCaseBodyTypeNotMatching() {
    let code = """
fun f (false, true) = 1
  | f (true, true) = true;
"""
    performFailingTest(code: code)
  }
  
  func testFunBindingCaseParameterTypeNotMatching() {
    let code = """
fun f (false, true) = 1
  | f (10, true) = 2;
"""
    performFailingTest(code: code)
  }
  
  func testFunBindingRedundantCase() {
    let code = """
fun f (false, true) = 1
  | f (a, true) = 2;
"""
    performFailingTest(code: code)
  }
  
  func testFunBindingCasesShouldSucceed() {
    let code = """
fun f (false, true) = 1
  | f (true, true) = 2;
"""
    performSucceedingTest(code: code)
  }
  
  func testFunBindingCasesWithDatatypeShouldSucceed() {
    let code = """
datatype A = X | Y;

fun f X = 1
  | f Y = 2;
"""
    performSucceedingTest(code: code)
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
