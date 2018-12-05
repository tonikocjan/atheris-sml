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
  func testValBinding() {
    let code = """
val (x, (a, c)) = "a string";
val x: int = 10;
"""
    testSyntaxParsing(code: code, expected: "ast1")
  }
  
  func testValBinding2() {
    let code = """
val (x, y) = 10;
val a = x;
val b = y;
"""
    testSyntaxParsingAndSemantics(code: code, expected: "ast2")
  }
  
  func testTupleExpression() {
    let code = """
val (x, y) = (10, 20, 30);
"""
    testSyntaxParsing(code: code, expected: "ast3")
  }
  
  func testTupleExpression2() {
    let code = """
val (x, (a, b)): (int * (int * int)) = (10, (20, 30));
val y = a;
"""
    testSyntaxParsingAndSemantics(code: code, typeCheck: true, expected: "ast4")
  }
  
  func testBinaryExpressions() {
    let code = """
val x = 10 + 20 * 30 / 40;
val y = ~10;
val z = true + ~10;
val a = true andalso false orelse 5 > 3;
val b = (10 + 5) * 2;
val c = 10 >= 5 andalso true = false;
val d = 10 <= 5;
"""
    testSyntaxParsing(code: code, expected: "ast5")
  }
  
  func testBinaryExpressions2() {
    let code = """
val x = 10 + 20;
val y = 10.5 / 2.3;
val z = true andalso 10 < 5;
val a = 5 <= 10 andalso 2.5 >= 3.2;
val b = true = true andalso 5 = 5 andalso "abc" = "efg" andalso 5 * 5 < 13 orelse 3.3 - 2.3 > 0.0;
val c = "123" ^ "456";
"""
    testSyntaxParsingAndSemantics(code: code, typeCheck: true, expected: "ast6")
  }
  
  func testLetExpression() {
    let code = """
val x = let val x = 10 in x end;
"""
    testSyntaxParsingAndSemantics(code: code, typeCheck: true, expected: "ast7")
  }
  
  func testFunctionDefinitionsAndCall() {
    let code = """
fun a (x, y, z) a = x ^ y ^ z;
fun b (x, y, z) = x ^ y ^ "abc";
fun c (x, y, z) = x + y + 10;
fun d (x, y, z) = x > 10 andalso true andalso y orelse z;
fun e (x, y, z) = x > 10 andalso true andalso y orelse z;

val v = a ("abc", "efg", "cdf");
"""
    testSyntaxParsingAndSemantics(code: code, typeCheck: true, expected: "ast8")
  }
}

private extension SyntaxParserTests {
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
  
  func testSyntaxParsingAndSemantics(code: String, typeCheck: Bool=false, expected filepath: String?) {
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
      if typeCheck { try typeChecker.visit(node: ast) }
      XCTAssertEqual(openAst(filepath),
                     astToString(ast, symbolDescription: symbolDescription))
    } catch {
      print((error as? AtherisError)?.errorMessage ?? error.localizedDescription)
      XCTFail()
    }
  }
  
  func astToString(_ ast: AstBindings?, symbolDescription: SymbolDescription?=nil) -> String {
    guard let ast = ast else { return "" }
    let stream = TextOutputStream()
    let visitor = DumpVisitor(outputStream: stream, symbolDescription: symbolDescription)
    try? visitor.visit(node: ast)
    return stream.buffer
  }
  
  func openAst(_ ast: String?) -> String? {
    guard let ast = ast else { return nil }
    let path = "/Users/tonikocjan/swift/Atheris/Atheris tests/Syntax/Asts/\(ast)"
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
