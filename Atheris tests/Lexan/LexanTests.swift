//
//  LexanTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 06/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

@testable import Atheris
import XCTest

class LexanTests: XCTestCase {
  func testEmpty() {
    XCTAssertEqual("[1:1, 1:2] EOF: $", generateSymbols("").first?.description)
  }
  
  func testParseNumeric() {
    XCTAssertEqual("[1:1, 1:5] INT_CONST: 1000", generateSymbols("1000").first?.description)
    XCTAssertEqual("[1:1, 1:4] INT_CONST: 999", generateSymbols("999").first?.description)
    XCTAssertEqual("[1:1, 1:2] INT_CONST: 0", generateSymbols("0").first?.description)
    XCTAssertEqual("[1:1, 1:11] INT_CONST: 0123456789", generateSymbols("0123456789").first?.description)
    XCTAssertEqual("[1:3, 1:4] INT_CONST: 0", generateSymbols("  0").first?.description)
    XCTAssertEqual("[1:1, 1:7] FLOAT_CONST: 3.1417", generateSymbols("3.1417").first?.description)
    XCTAssertEqual("[1:1, 1:7] FLOAT_CONST: 3.1417", generateSymbols("3.1417.12").first?.description)
    XCTAssertEqual("[1:7, 1:8] DOT: .", generateSymbols("3.1417.12")[1].description)
    XCTAssertEqual("[1:8, 1:10] INT_CONST: 12", generateSymbols("3.1417.12")[2].description)
  }
  
  func testParseOperator() {
    XCTAssertEqual("[1:1, 1:2] ASSIGN: =", generateSymbols("=").first?.description)
    XCTAssertEqual("[1:1, 1:2] LPARENT: (", generateSymbols("(").first?.description)
    XCTAssertEqual("[1:1, 1:2] RPARENT: )", generateSymbols(")").first?.description)
    XCTAssertEqual("[1:1, 1:2] LBRACKET: [", generateSymbols("[").first?.description)
    XCTAssertEqual("[1:1, 1:2] RBRACKET: ]", generateSymbols("]").first?.description)
    XCTAssertEqual("[1:1, 1:2] LBRACE: {", generateSymbols("{").first?.description)
    XCTAssertEqual("[1:1, 1:2] RBRACE: }", generateSymbols("}").first?.description)
    XCTAssertEqual("[1:1, 1:2] DOT: .", generateSymbols(".").first?.description)
    XCTAssertEqual("[1:1, 1:2] SEMICOLON: ;", generateSymbols(";").first?.description)
    XCTAssertEqual("[1:1, 1:2] COLON: :", generateSymbols(":").first?.description)
    XCTAssertEqual("[1:1, 1:2] LTH: <", generateSymbols("<").first?.description)
    XCTAssertEqual("[1:1, 1:2] GTH: >", generateSymbols(">").first?.description)
    XCTAssertEqual("[1:1, 1:2] COMMA: ,", generateSymbols(",").first?.description)
    XCTAssertEqual("[1:1, 1:2] NOT: !", generateSymbols("!").first?.description)
    XCTAssertEqual("[1:1, 1:2] MUL: *", generateSymbols("*").first?.description)
    XCTAssertEqual("[1:1, 1:2] DIV: /", generateSymbols("/").first?.description)
    XCTAssertEqual("[1:1, 1:2] ADD: +", generateSymbols("+").first?.description)
    XCTAssertEqual("[1:1, 1:2] SUB: -", generateSymbols("-").first?.description)
    XCTAssertEqual("[1:1, 1:3] EQU: ==", generateSymbols("==").first?.description)
    XCTAssertEqual("[1:1, 1:3] NEQ: !=", generateSymbols("!=").first?.description)
    XCTAssertEqual("[1:1, 1:3] GEQ: >=", generateSymbols(">=").first?.description)
    XCTAssertEqual("[1:1, 1:3] LEQ: <=", generateSymbols("<=").first?.description)
    XCTAssertEqual("[1:1, 1:3] OR: ||", generateSymbols("||").first?.description)
    XCTAssertEqual("[1:1, 1:3] AND: &&", generateSymbols("&&").first?.description)
  }
  
  func testKeywords() {
    XCTAssertEqual(TokenType.keywordElse, generateSymbols("else").first?.tokenType)
    XCTAssertEqual(TokenType.keywordFor, generateSymbols("for").first?.tokenType)
    XCTAssertEqual(TokenType.keywordFun, generateSymbols("func").first?.tokenType)
    XCTAssertEqual(TokenType.keywordIf, generateSymbols("if").first?.tokenType)
    XCTAssertEqual(TokenType.keywordVar, generateSymbols("var").first?.tokenType)
    XCTAssertEqual(TokenType.keywordWhile, generateSymbols("while").first?.tokenType)
    XCTAssertEqual(TokenType.keywordStruct, generateSymbols("struct").first?.tokenType)
    XCTAssertEqual(TokenType.keywordImport, generateSymbols("import").first?.tokenType)
    XCTAssertEqual(TokenType.keywordLet, generateSymbols("let").first?.tokenType)
    XCTAssertEqual(TokenType.keywordNull, generateSymbols("null").first?.tokenType)
    XCTAssertEqual(TokenType.keywordClass, generateSymbols("class").first?.tokenType)
    XCTAssertEqual(TokenType.keywordIn, generateSymbols("in").first?.tokenType)
    XCTAssertEqual(TokenType.keywordReturn, generateSymbols("return").first?.tokenType)
    XCTAssertEqual(TokenType.keywordPublic, generateSymbols("public").first?.tokenType)
    XCTAssertEqual(TokenType.keywordPrivate, generateSymbols("private").first?.tokenType)
    XCTAssertEqual(TokenType.keywordContinue, generateSymbols("continue").first?.tokenType)
    XCTAssertEqual(TokenType.keywordBreak, generateSymbols("break").first?.tokenType)
    XCTAssertEqual(TokenType.keywordSwitch, generateSymbols("switch").first?.tokenType)
    XCTAssertEqual(TokenType.keywordCase, generateSymbols("case").first?.tokenType)
    XCTAssertEqual(TokenType.keywordDefault, generateSymbols("default").first?.tokenType)
    XCTAssertEqual(TokenType.keywordBreak, generateSymbols("break").first?.tokenType)
    XCTAssertEqual(TokenType.keywordSwitch, generateSymbols("switch").first?.tokenType)
    XCTAssertEqual(TokenType.keywordCase, generateSymbols("case").first?.tokenType)
    XCTAssertEqual(TokenType.keywordDefault, generateSymbols("default").first?.tokenType)
    XCTAssertEqual(TokenType.keywordEnum, generateSymbols("enum").first?.tokenType)
    XCTAssertEqual(TokenType.keywordInit, generateSymbols("init").first?.tokenType)
    XCTAssertEqual(TokenType.keywordIs, generateSymbols("is").first?.tokenType)
    XCTAssertEqual(TokenType.keywordAs, generateSymbols("as").first?.tokenType)
    XCTAssertEqual(TokenType.keywordOverride, generateSymbols("override").first?.tokenType)
    XCTAssertEqual(TokenType.keywordExtension, generateSymbols("extension").first?.tokenType)
    XCTAssertEqual(TokenType.keywordFinal, generateSymbols("final").first?.tokenType)
    XCTAssertEqual(TokenType.keywordStatic, generateSymbols("static").first?.tokenType)
    XCTAssertEqual(TokenType.keywordInterface, generateSymbols("interface").first?.tokenType)
    XCTAssertEqual(TokenType.keywordAbstract, generateSymbols("abstract").first?.tokenType)
  }
  
  func testSimpleExpressions() {
    var symbols = generateSymbols("let x = 10")
    XCTAssertEqual(5, symbols.count)
    XCTAssertEqual("[1:1, 1:4] LET: let", symbols[0].description)
    XCTAssertEqual("[1:5, 1:6] IDENTIFIER: x", symbols[1].description)
    XCTAssertEqual("[1:7, 1:8] ASSIGN: =", symbols[2].description)
    XCTAssertEqual("[1:9, 1:11] INT_CONST: 10", symbols[3].description)
    XCTAssertEqual("[1:11, 1:12] EOF: $", symbols[4].description)
    
    symbols = generateSymbols("let x == 10")
    XCTAssertEqual(5, symbols.count)
    XCTAssertEqual("[1:1, 1:4] LET: let", symbols[0].description)
    XCTAssertEqual("[1:5, 1:6] IDENTIFIER: x", symbols[1].description)
    XCTAssertEqual("[1:7, 1:9] EQU: ==", symbols[2].description)
    XCTAssertEqual("[1:10, 1:12] INT_CONST: 10", symbols[3].description)
    XCTAssertEqual("[1:12, 1:13] EOF: $", symbols[4].description)
    
    symbols = generateSymbols("let x: Int")
    XCTAssertEqual(5, symbols.count)
    XCTAssertEqual("[1:1, 1:4] LET: let", symbols[0].description)
    XCTAssertEqual("[1:5, 1:6] IDENTIFIER: x", symbols[1].description)
    XCTAssertEqual("[1:6, 1:7] COLON: :", symbols[2].description)
    XCTAssertEqual("[1:8, 1:11] IDENTIFIER: Int", symbols[3].description)
    XCTAssertEqual("[1:11, 1:12] EOF: $", symbols[4].description)
  }
  
  func testExpressionsInMultipleLines() {
    let symbols = generateSymbols("""
let x = 10
x = 20
""")
    XCTAssertEqual(9, symbols.count)
    XCTAssertEqual("[1:1, 1:4] LET: let", symbols[0].description)
    XCTAssertEqual("[1:5, 1:6] IDENTIFIER: x", symbols[1].description)
    XCTAssertEqual("[1:7, 1:8] ASSIGN: =", symbols[2].description)
    XCTAssertEqual("[1:9, 1:11] INT_CONST: 10", symbols[3].description)
    XCTAssertEqual("[1:11, 1:12] NL: ", symbols[4].description)
    XCTAssertEqual("[2:1, 2:2] IDENTIFIER: x", symbols[5].description)
    XCTAssertEqual("[2:3, 2:4] ASSIGN: =", symbols[6].description)
    XCTAssertEqual("[2:5, 2:7] INT_CONST: 20", symbols[7].description)
    XCTAssertEqual("[2:7, 2:8] EOF: $", symbols[8].description)
  }
  
  func testSingleLineComment() {
    var symbols = generateSymbols("""
let x ///= 10 this is a comment
x = 20
""")
    XCTAssertEqual(7, symbols.count)
    XCTAssertEqual("[1:1, 1:4] LET: let", symbols[0].description)
    XCTAssertEqual("[1:5, 1:6] IDENTIFIER: x", symbols[1].description)
    XCTAssertEqual("[1:32, 1:33] NL: ", symbols[2].description)
    XCTAssertEqual("[2:1, 2:2] IDENTIFIER: x", symbols[3].description)
    XCTAssertEqual("[2:3, 2:4] ASSIGN: =", symbols[4].description)
    XCTAssertEqual("[2:5, 2:7] INT_CONST: 20", symbols[5].description)
    XCTAssertEqual("[2:7, 2:8] EOF: $", symbols[6].description)
    
    symbols = generateSymbols("// this is a comment")
    XCTAssertEqual(1, symbols.count)
    XCTAssertEqual(TokenType.eof, symbols[0].tokenType)
  }
  
  func testMultiLineComment() {
    var symbols = generateSymbols("""
/*
dweldklwed
dwledklwd
lwedklwe
*/
""")
    XCTAssertEqual(1, symbols.count)
    XCTAssertEqual(TokenType.eof, symbols[0].tokenType)
    
    symbols = generateSymbols("""
class a {}
/*
dweldklwed
dwledklwd
lwedklwe
*/

let x: Int
""")
    XCTAssertEqual(10, symbols.count)
    XCTAssertEqual(TokenType.keywordClass, symbols[0].tokenType)
    XCTAssertEqual(TokenType.identifier, symbols[1].tokenType)
    XCTAssertEqual(TokenType.leftBrace, symbols[2].tokenType)
    XCTAssertEqual(TokenType.rightBrace, symbols[3].tokenType)
    XCTAssertEqual(TokenType.newline, symbols[4].tokenType)
    XCTAssertEqual(TokenType.keywordLet, symbols[5].tokenType)
    XCTAssertEqual(TokenType.identifier, symbols[6].tokenType)
    XCTAssertEqual(TokenType.colon, symbols[7].tokenType)
    XCTAssertEqual(TokenType.identifier, symbols[8].tokenType)
    XCTAssertEqual(TokenType.eof, symbols[9].tokenType)
  }
  
  func testIdentifier() {
    XCTAssertEqual(TokenType.identifier, generateSymbols("ident1").first?.tokenType)
    XCTAssertEqual("ident1", generateSymbols("ident1").first?.lexeme)
    XCTAssertEqual(TokenType.integerConstant, generateSymbols("1ident").first?.tokenType)
    XCTAssertEqual("ident", generateSymbols("1ident")[1].lexeme)
    XCTAssertEqual(TokenType.integerConstant, generateSymbols("1ident").first?.tokenType)
    XCTAssertEqual("_", generateSymbols("_")[0].lexeme)
    XCTAssertEqual(TokenType.identifier, generateSymbols("_")[0].tokenType)
    XCTAssertEqual("abc_", generateSymbols("abc_")[0].lexeme)
    XCTAssertEqual(TokenType.identifier, generateSymbols("abc_")[0].tokenType)
  }
  
  func testStringConstant() {
    var symbols = generateSymbols("\"this is a string\"")
    XCTAssertEqual(2, symbols.count)
    XCTAssertEqual("[1:1, 1:19] STRING_CONST: this is a string", symbols[0].description)
    
    symbols = generateSymbols("a = \"this is a string\";")
    XCTAssertEqual(5, symbols.count)
    XCTAssertEqual(";", symbols[3].lexeme)
    
    XCTAssertEqual(TokenType.nonEscapedStringConstant, generateSymbols("\"a").first?.tokenType)
    
    symbols = generateSymbols("\"this is \"a string\";")
    XCTAssertEqual(5, symbols.count)
    XCTAssertEqual(TokenType.stringConstant, symbols[0].tokenType)
    XCTAssertEqual(TokenType.identifier, symbols[1].tokenType)
    XCTAssertEqual(TokenType.identifier, symbols[2].tokenType)
    XCTAssertEqual(TokenType.nonEscapedStringConstant, symbols[3].tokenType)
    XCTAssertEqual(TokenType.eof, symbols[4].tokenType)
  }
  
  func testBooleanConstant() {
    var symbols = generateSymbols("true == false")
    XCTAssertEqual(4, symbols.count)
    XCTAssertEqual("[1:1, 1:5] LOG_CONST: true", symbols[0].description)
    XCTAssertEqual("[1:6, 1:8] EQU: ==", symbols[1].description)
    XCTAssertEqual("[1:9, 1:14] LOG_CONST: false", symbols[2].description)
    XCTAssertEqual("[1:14, 1:15] EOF: $", symbols[3].description)
  }
  
  func testEndToEndTest() {
    //    let reader = try! FileReader(fileUrl: URL(string: "/Users/tonikocjan/swift/Atheris tests/Lexan/test.ar")!)
    //    let stream = FileInputStream(fileReader: reader)
    //    let lexan = LexAn(stream: stream)
    //    while true {
    //      let symbol = lexan.nextSymbol()
    //
    //      if symbol.tokenType == .eof { break }
    //    }
  }
}

private extension LexanTests {
  class TextStream: InputStream {
    let string: String
    private var it = 0
    
    init(string: String) {
      self.string = string
    }
    
    func next() throws -> Character {
      guard it < string.count else { throw NSError(domain: "Empty string", code: 0, userInfo: nil) }
      it += 1
      return string[string.index(string.startIndex, offsetBy: it - 1)]
    }
  }
  
  func generateSymbols(_ string: String) -> [Symbol] {
    let lexan = LexAn(inputStream: TextStream(string: string))
    return lexan.map { $0 }
  }
}
