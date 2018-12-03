//
//  SyntaxParserTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

@testable import Atheris
import XCTest

class SyntaxParserTests: XCTestCase {
  func testAst1() {
    let code = """
val (x, (a, c)) = "a string";
val x: int = 10;
"""
    testSyntaxParsing(code: code, expected: "ast1")
  }
}

private extension SyntaxParserTests {
  class TextOutputStream: OutputStream {
    private(set) var buffer = ""
    
    func print(_ string: String) {
      buffer.append(string)
    }
    
    func printLine(_ string: String) {
      buffer.append(string + "\n")
    }
  }
  
  func testSyntaxParsing(code: String, expected filepath: String?) {
    do {
      let lexan = LexAn(inputStream: TextStream(string: code))
      let parser = SynAn(lexan: lexan)
      let ast = try parser.parse()
      XCTAssertEqual(openAst(filepath), astToString(ast))
    } catch {
      print((error as? AtherisError)?.errorMessage ?? error.localizedDescription)
      XCTFail()
    }
  }
  
  func astToString(_ ast: AstBindings?) -> String {
    guard let ast = ast else { return "" }
    let stream = TextOutputStream()
    let visitor = DumpVisitor(outputStream: stream)
    try? visitor.visit(node: ast)
    return stream.buffer
  }
  
  func openAst(_ ast: String?) -> String? {
    guard let ast = ast else { return nil }
    let path = "/Users/tonikocjan/swift/Atheris/Atheris tests/Syntax/Asts/\(ast)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    do {
      let fileReader = try FileReader(fileUrl: URL(string: path)!)
      var result = ""
      while let line = fileReader.readLine() {
        result += line
      }
      return result
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
}
