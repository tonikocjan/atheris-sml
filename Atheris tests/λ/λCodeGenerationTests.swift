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
    performTest(code: "val a = true;", expected: "let a = \\x.\\y.x")
    performTest(code: "val a = false;", expected: "let a = \\x.\\y.y")
  }
  
  func testBinaryOperations() {
    performTest(code: "10 + 20;", expected: "((+10)20)")
  }
  
  func testIfThenElse() {
    performTest(code: "if 10 = 10 then true else false;", expected: "((((=10)10)\\x.\\y.x)\\x.\\y.y)")
  }
  
  func testFunctions() {
    performTest(code: "fun f x = x; f 10;", expected: "let f = \\x.x\n(f10)")
    performTest(code: "fun f x y = x + y; f 10 20;", expected: "let f = \\x.\\y.((+x)y)\n((f10)20)")
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
}
