//
//  CodeGenerationTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import XCTest

class CodeGenerationTests: XCTestCase {
  func testBinaryAndUnaryExpressions() {
    let code = """
val x = 10 + 20;
val y = 10.5 / 2.3;
val z = true andalso 10 < 5;
val a = 5 <= 10 andalso 2.5 >= 3.2;
val b = true = true andalso 5 = 5 andalso "abc" = "efg" andalso 5 * 5 < 13 orelse 3.3 - 2.3 > 0.0;
val c = "123" ^ "456";
val d = ~1;
val e = 5 mod 2;
val f = not true;
"""
    performTest(code: code, filepath: "code1.rkt")
  }
  
  func testIfExpression() {
    let code = """
val x = if 3 < 4 then "a" else "b";
"""
    performTest(code: code, filepath: "code2.rkt")
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

val a = ((x (20)) (30)) (fn (x, y) => x + y);
val b = ((x ("abc")) ("efg")) (fn (x, y) => x ^ y);
val c = x 20 30 (fn (x, y) => x + y);
val d = x "abc" "efg" (fn (x, y) => x ^ y);
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
  
  func testDatatype() {
    // TODO: - 
    let code = """
datatype prevozno_sredstvo_t =
  Bus of int
  | Avto of (string*string*int)
  | Pes;

val x = Bus 10;
val y = Avto ("abc", "efg", 10);
val z = Pes;
val a = x::[y, z];
"""
    performTest(code: code, filepath: "code10.rkt")
  }
  
  func testNestedDatatypePatternMatching() {
    let code = """
val x = 10;
val y = false;

datatype D = X | Y;

val z = case (x, Y) of
  (10, X) => true
  | (10, Y) => false;

val e = case (true, (true, true)) of
  (true, (true, true)) => 0
  | (true, (true, false)) => 1
  | (true, (false, true)) => 2
  | (true, (false, false)) => 3
  | (false, (true, true)) => 4
  | (false, (true, false)) => 5
  | (false, (false, true)) => 6
  | (false, (false, false)) => 7;
"""
    performTest(code: code, filepath: "code11.rkt")
  }
  
  func testDatatypeMethod() {
    let code = """
datatype natural = NEXT of natural | ZERO;

fun toInt (a) =
  case a of
    ZERO => 0
    | NEXT i => 1 + toInt(i);

val x = NEXT(ZERO);
val a = toInt x;
"""
    performTest(code: code, filepath: "code12.rkt")
  }
  
  func testFunBindingWithCasesSimpleBoolean() {
    let code = """
fun f true = 1
  | f false = 2;

val x = f true;
val y = f false;
"""
    performTest(code: code, filepath: "code13.rkt")
  }
  
  func testFunBindingWithCasesDatatype() {
    let code = """
datatype A = X | Y;

fun f X = 1
  | f Y = 2;

val x = f X;
val y = f Y;
"""
    performTest(code: code, filepath: "code14.rkt")
  }
  
  func testFunBindingWithCasesDatatypeAndBoolean() {
    let code = """
datatype A = X | Y;

fun f (X, true) = 1
  | f (X, false) = 2
  | f (Y, true) = 3
  | f (Y, false) = 4;

val a = f (X, true);
val b = f (X, false);
val c = f (Y, true);
val d = f (Y, false);
"""
    performTest(code: code, filepath: "code15.rkt")
  }
  
  func testHugeExample1() {
    performTest(code: loadSMLCode("sml1.sml"),
                filepath: "code16.rkt")
  }
  
  func testHugeExample2() {
    performTest(code: loadSMLCode("sml2.sml"),
                filepath: "code17.rkt")
  }
  
  func testListPatternMatching() {
    let code = """
val x = [2, 3, 4, 5];
case x of
  [] => 1
  | h1::h2::h3::t => 2
  | h1::h2::t => 3
  | h::t => 4;
"""
    performTest(code: code,
                filepath: "code18.rkt")
  }
  
  func testRecursiveListPatternMatching() {
    let code = """
val xs = [false, false, true];

case xs of
  true::tl => 1
  | false::tl => 2;

val xss = [(true, 20, true), (true, 20, false), (false, 30, false)];
case xss of
  (true, 20, true)::tl => 1
  | (false, 10, true)::tl => 2
  | (true, 12, true)::tl => 3;
"""
    performTest(code: code,
                filepath: "code19.rkt")
  }
  
  func testDatatypeWithTypeConstructor() {
    // TODO: -
    let code = """
datatype ('a) Opcija = JE of 'a | NI;
fun f x: int Opcija = NI;
"""
    performTest(code: code, filepath: "code17.rkt")
  }
  
  func testFunctionWithAbstractType() {
    // TODO: -
    let code = """
fun f (a: 'a -> int) = a;
"""
    performTest(code: code, filepath: "code18.rkt")
  }
  
  func testTupleBinding() {
    let code = """
val (x, y, z) = (10, 20, 30);
"""
    performTest(code: code, filepath: "code3.rkt")
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
      XCTAssertEqual(outputStream.buffer, loadRacketCode(filepath))
    } catch {
      print((error as? AtherisError)?.errorMessage ?? error.localizedDescription)
      XCTFail()
    }
  }
  
  func loadRacketCode(_ file: String?) -> String? {
    guard let file = file else { return nil }
    let path = "/Users/tonikocjan/swift/Atheris/Atheris tests/Code generation/Code/\(file)"
      .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    do {
      let fileReader = try FileReader(fileUrl: URL(string: path)!)
      let lines = fileReader.readLines()
      return lines.joined(separator: "\n").appending("\n")
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
  
  func loadSMLCode(_ file: String) -> String {
    let path = "/Users/tonikocjan/swift/Atheris/Atheris tests/Code generation/Code/\(file)"
      .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    do {
      let fileReader = try FileReader(fileUrl: URL(string: path)!)
      let lines = fileReader.readLines()
      return lines.joined(separator: "\n")
    } catch {
      print(error.localizedDescription)
      return ""
    }
  }
}
