//
//  CodeGenerationTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import XCTest

class CodeGenerationTests: XCTestCase {
  func testBinaryExpressions() {
    let code = """
val x = 10 + 20;
val y = 10.5 / 2.3;
val z = true andalso 10 < 5;
val a = 5 <= 10 andalso 2.5 >= 3.2;
val b = true = true andalso 5 = 5 andalso "abc" = "efg" andalso 5 * 5 < 13 orelse 3.3 - 2.3 > 0.0;
val c = "123" ^ "456";
"""
    performTest(code: code, filepath: "code1.rkt")
  }
  
  func testIfExpression() {
    let code = """
val x = if 3 < 4 then "a" else "b";
"""
    performTest(code: code, filepath: "code2.rkt")
  }
  
  func testTupleBinding() {
    let code = """
val (x, y, z) = (10, 20, 30);
"""
    performTest(code: code, filepath: "code3.rkt")
  }
  
  func testFunctionBindingsAndCall() {
    let code = """
fun a (x, y, z) a = x ^ y ^ z;
fun b (x, y, z) = x ^ y ^ "abc";
fun c (x, y, z) = x + y + 10;
fun d (x, y, z) = x > 10 andalso true andalso y orelse z;
fun e (x, y, z) = x > 10 andalso true andalso y orelse z;

val v = a ("abc", "efg", "cdf");
"""
    performTest(code: code, filepath: "code4.rkt")
  }
  
  func testLocalFunctionAndRecursion() {
    let code = """
fun pow (x, y) =
  let
    fun pow (x, y) =
      if y = 0 then 1
      else x * pow (x, y - 1)
  in
    pow (x, y)
  end;
val x = pow (3, 3);
"""
    performTest(code: code, filepath: "code5.rkt")
  }
  
  func testCurrying() {
    let code = """
fun mul x y z = x * y * z;
val x = ((mul (10)) (20)) (30);
"""
    performTest(code: code, filepath: "code6.rkt")
  }
  
  func testAnonymousFunctionAsApplication() {
    let code = """
val x = fn x => fn y => fn z => z (x, y);
val y = ((x (20)) (30)) (fn (x, y) => x + y);
val z = ((x ("abc")) ("efg")) (fn (x, y) => x ^ y);
"""
    performTest(code: code, filepath: "code7.rkt")
  }
  
  func testRecordAndRecordSelection() {
    let code = """
val x = {a = 10, b = "string", promise = {evaled = false, f = fn x => x * x}};
val a = (#f (#promise x)) (10);
"""
    performTest(code: code, filepath: "code8.rkt")
  }
  
  func testListExpression() {
    let code = """
val x = [1, 2, 3];
val y = 1::2::[3];
"""
    performTest(code: code, filepath: "code9.rkt")
  }
}

private extension CodeGenerationTests {
  func performTest(code: String, filepath: String) {
    do {
      let lexan = LexAn(inputStream: TextStream(string: code))
      let parser = SynAn(lexan: lexan)
      let ast = try parser.parse()
      let symbolDescription = SymbolDescription()
      let nameChecker = NameChecker(symbolTable: SymbolTable(symbolDescription: symbolDescription),
                                    symbolDescription: symbolDescription)
      let typeChecker = TypeChecker(symbolTable: nameChecker.symbolTable,
                                    symbolDescription: nameChecker.symbolDescription)
      try nameChecker.visit(node: ast)
      try typeChecker.visit(node: ast)
      let outputStream = TextOutputStream()
      let codeGenerator = RacketCodeGenerator(outputStream: outputStream,
                                              configuration: RacketCodeGenerator.Configuration(indentation: 2,
                                                                                               pretty: true,
                                                                                               printWelcome: false),
                                              symbolDescription: symbolDescription)
      try codeGenerator.visit(node: ast)
      XCTAssertEqual(outputStream.buffer, loadCode(filepath))
    } catch {
      print((error as? AtherisError)?.errorMessage ?? error.localizedDescription)
      XCTFail()
    }
  }
  
  func loadCode(_ file: String?) -> String? {
    guard let file = file else { return nil }
    let path = "/Users/tonikocjan/swift/Atheris/Atheris tests/Code generation/Code/\(file)"
      .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    do {
      let fileReader = try FileReader(fileUrl: URL(string: path)!)
      var result = ""
      while let line = fileReader.readLine() {
        result += line + "\n"
      }
      return result
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
}
