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
    performTest(code: "val a = 10;", tree: .binding(v: "a", expression: .constant(value: 10)))
    performTest(code: "val a = true;", tree: .binding(v: "a", expression: .abstraction(variable: "x",
                                                                                       expression: .abstraction(variable: "y",
                                                                                                                expression: .variable(name: "x")))))
    performTest(code: "val a = false;", tree: .binding(v: "a", expression: .abstraction(variable: "x",
                                                                                        expression: .abstraction(variable: "y",
                                                                                                                 expression: .variable(name: "y")))))
  }
  
  func testBinaryOperations() {
    performTest(code: "10 + 20;", tree: .application(fn: .application(fn: .variable(name: "+"),
                                                                      value: .constant(value: 10)),
                                                     value: .constant(value: 20)))
  }
}

private extension λCodeGenerationTests {
  func performTest(code: String, tree: Tree) {
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
      XCTAssertEqual(outputStream.buffer.trimmingCharacters(in: ["\n"]), tree.description)
    } catch {
      print((error as? AtherisError)?.errorMessage ?? error.localizedDescription)
      XCTFail()
    }
  }
}
