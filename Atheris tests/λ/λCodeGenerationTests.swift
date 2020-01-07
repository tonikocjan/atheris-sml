//
//  λCodeGenerationTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 26/12/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import XCTest
@testable import Atheris

class λCodeGenerationTests: XCTestCase {
  typealias Tree = λcalculusGenerator.Tree
  
  func testSimpleConstants() {
    performTest(code: "val a = 10;", expected: "let a = 10")
    performTest(code: "val a = true;", expected: #"let a = (\x.(\y.x))"#)
    performTest(code: "val a = false;", expected: #"let a = (\x.(\y.y))"#)
  }
  
  func testBinaryOperations() {
    performTest(code: "10 + 20;", expected: "((+10)20)")
    performTest(code: "10 - 20;", expected: "((-10)20)")
    performTest(code: "10 * 20;", expected: "((*10)20)")
    performTest(code: "10.0 / 20.0;", expected: "((/10)20)")
    performTest(code: "10 = 20;", expected: "((=10)20)")
  }
  
  func testUnaryOperations() {
    performTest(code: "~10;", expected: "((-0)10)")
    performTest(code: "not true;", expected: #"(((\x.(\y.x))(\x.(\y.y)))(\x.(\y.x)))"#)
    performTest(code: "not false;", expected: #"(((\x.(\y.y))(\x.(\y.y)))(\x.(\y.x)))"#)
  }
  
  func testIfThenElse() {
    performTest(code: "if 10 = 10 then true else false;", expected: #"((((=10)10)(\x.(\y.x)))(\x.(\y.y)))"#)
  }
  
  func testFunctions() {
    performTest(code: "fun f x = x; f 10;", expected: #"let f = (\x.x)\#n(f10)"#)
    performTest(code: "fun f x y = x + y; f 10 20;", expected: #"let f = (\x.(\y.((+x)y)))\#n((f10)20)"#)
  }
  
  func testTuple() {
    performTest(code: """
val x = (10, 20, 30, 40, 50);
#1 x;
#2 x;
#3 x;
#4 x;
#5 x;
""", loadFromFile: "Tuple")
  }
  
  func testDatatypeBinding() {
    performTest(code: """
datatype A =
  X of int
  | Y of int
  | Z;

case X 10 of
  X a => 1
  | Y a => 2
  | Z => 0;

case Y 10 of
  X a => 1
  | Y a => 2
  | Z => 0;

case Z of
  X a => 1
  | Y a => 2
  | Z => 0;
""", loadFromFile: "Datatype")
  }
  
  func testOptionFunctor() {
    performTest(code: #"""
datatype 'a O = J of 'a | N;
fun m x f = case x of J l => J (f l) | N => N;

val x = m (J 10) (fn x => x * x);
case x of
  J x => x
  | N => 0;
"""#, loadFromFile: "TupleFunctor")
  }
}

private extension λCodeGenerationTests {
  func performTest(code: String, expected: String) {
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
      let treeGenerator = λcalculusGenerator(symbolDescription: symbolDescription)
      try treeGenerator.visit(node: ast)
      let codeGenerator = λcalculusCodeGen(outputStream: outputStream, mapping: treeGenerator.table)
      try codeGenerator.visit(node: ast)
      XCTAssertEqual(outputStream.buffer.trimmingCharacters(in: ["\n"]), expected)
    } catch {
      print((error as? AtherisError)?.errorMessage ?? error.localizedDescription)
      XCTFail()
    }
  }
  
  func performTest(code: String, loadFromFile file: String) {
    let file = loadFile(file)
    performTest(code: code, expected: file)
  }
  
  func loadFile(_ file: String) -> String {
    do {
      guard let path = Bundle(for: type(of: self)).url(forResource: file, withExtension: nil) else { fatalError() }
      let code = String(data: try Data(contentsOf: path), encoding: .utf8)?.trimmingCharacters(in: ["\n"])
      return code ?? ""
    } catch {
      print(error.localizedDescription)
      fatalError()
    }
  }
}
