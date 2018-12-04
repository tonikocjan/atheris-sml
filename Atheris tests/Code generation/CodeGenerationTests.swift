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
val y = x > 10 + 5 andalso true;
"""
    performTest(code: code, filepath: "code1.rkt")
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
      let codeGenerator = RacketCodeGenerator(outputStream: outputStream, configuration: .standard)
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
