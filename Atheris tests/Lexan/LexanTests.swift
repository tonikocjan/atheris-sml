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
    XCTAssertEqual(TokenType.invalidCharacter, generateSymbols(".12").first?.tokenType)
  }
  
  func testParseOperator() {
    XCTAssertEqual("[1:1, 1:2] ASSIGN: =", generateSymbols("=").first?.description)
    XCTAssertEqual("[1:1, 1:2] LPARENT: (", generateSymbols("(").first?.description)
    XCTAssertEqual("[1:1, 1:2] RPARENT: )", generateSymbols(")").first?.description)
    XCTAssertEqual("[1:1, 1:2] LBRACKET: [", generateSymbols("[").first?.description)
    XCTAssertEqual("[1:1, 1:2] RBRACKET: ]", generateSymbols("]").first?.description)
    XCTAssertEqual("[1:1, 1:2] LBRACE: {", generateSymbols("{").first?.description)
    XCTAssertEqual("[1:1, 1:2] RBRACE: }", generateSymbols("}").first?.description)
    XCTAssertEqual("[1:1, 1:2] SEMICOLON: ;", generateSymbols(";").first?.description)
    XCTAssertEqual("[1:1, 1:2] COLON: :", generateSymbols(":").first?.description)
    XCTAssertEqual("[1:1, 1:2] COMMA: ,", generateSymbols(",").first?.description)
    XCTAssertEqual("[1:1, 1:2] PIPE: |", generateSymbols("|").first?.description)
  }
  
  func testKeywords() {
    XCTAssertEqual(TokenType.keywordModulo, generateSymbols("mod").first?.tokenType)
    XCTAssertEqual(TokenType.keywordNot, generateSymbols("not").first?.tokenType)
    XCTAssertEqual(TokenType.keywordAbstype, generateSymbols("abstype").first?.tokenType)
    XCTAssertEqual(TokenType.keywordAnd, generateSymbols("and").first?.tokenType)
    XCTAssertEqual(TokenType.keywordAndalso, generateSymbols("andalso").first?.tokenType)
    XCTAssertEqual(TokenType.keywordAs, generateSymbols("as").first?.tokenType)
    XCTAssertEqual(TokenType.keywordCase, generateSymbols("case").first?.tokenType)
    XCTAssertEqual(TokenType.keywordDatatype, generateSymbols("datatype").first?.tokenType)
    XCTAssertEqual(TokenType.keywordDo, generateSymbols("do").first?.tokenType)
    XCTAssertEqual(TokenType.keywordElse, generateSymbols("else").first?.tokenType)
    XCTAssertEqual(TokenType.keywordEnd, generateSymbols("end").first?.tokenType)
    XCTAssertEqual(TokenType.keywordException, generateSymbols("exception").first?.tokenType)
    XCTAssertEqual(TokenType.keywordFn, generateSymbols("fn").first?.tokenType)
    XCTAssertEqual(TokenType.keywordFun, generateSymbols("fun").first?.tokenType)
    XCTAssertEqual(TokenType.keywordHandle, generateSymbols("handle").first?.tokenType)
    XCTAssertEqual(TokenType.keywordIf, generateSymbols("if").first?.tokenType)
    XCTAssertEqual(TokenType.keywordIn, generateSymbols("in").first?.tokenType)
    XCTAssertEqual(TokenType.keywordInfix, generateSymbols("infix").first?.tokenType)
    XCTAssertEqual(TokenType.keywordInfixr, generateSymbols("infixr").first?.tokenType)
    XCTAssertEqual(TokenType.keywordLet, generateSymbols("let").first?.tokenType)
    XCTAssertEqual(TokenType.keywordLocal, generateSymbols("local").first?.tokenType)
    XCTAssertEqual(TokenType.keywordNonfix, generateSymbols("nonfix").first?.tokenType)
    XCTAssertEqual(TokenType.keywordOf, generateSymbols("of").first?.tokenType)
    XCTAssertEqual(TokenType.keywordOp, generateSymbols("op").first?.tokenType)
    XCTAssertEqual(TokenType.keywordOpen, generateSymbols("open").first?.tokenType)
    XCTAssertEqual(TokenType.keywordOrelse, generateSymbols("orelse").first?.tokenType)
    XCTAssertEqual(TokenType.keywordRaise, generateSymbols("raise").first?.tokenType)
    XCTAssertEqual(TokenType.keywordRec, generateSymbols("rec").first?.tokenType)
    XCTAssertEqual(TokenType.keywordThen, generateSymbols("then").first?.tokenType)
    XCTAssertEqual(TokenType.keywordType, generateSymbols("type").first?.tokenType)
    XCTAssertEqual(TokenType.keywordVal, generateSymbols("val").first?.tokenType)
    XCTAssertEqual(TokenType.keywordWith, generateSymbols("with").first?.tokenType)
    XCTAssertEqual(TokenType.keywordWithtype, generateSymbols("withtype").first?.tokenType)
    XCTAssertEqual(TokenType.keywordWhile, generateSymbols("while").first?.tokenType)
  }
  
  func testSimpleExpressions() {
    var symbols = generateSymbols("val x = 10;")
    XCTAssertEqual(6, symbols.count)
    if symbols.count == 6 {
      XCTAssertEqual("[1:1, 1:4] VAL: val", symbols[0].description)
      XCTAssertEqual("[1:5, 1:6] IDENTIFIER: x", symbols[1].description)
      XCTAssertEqual("[1:7, 1:8] ASSIGN: =", symbols[2].description)
      XCTAssertEqual("[1:9, 1:11] INT_CONST: 10", symbols[3].description)
      XCTAssertEqual("[1:11, 1:12] SEMICOLON: ;", symbols[4].description)
      XCTAssertEqual("[1:12, 1:13] EOF: $", symbols[5].description)
    }
    
    symbols = generateSymbols("fun f = 10;")
    XCTAssertEqual(6, symbols.count)
    if symbols.count == 6 {
      XCTAssertEqual("[1:1, 1:4] FUN: fun", symbols[0].description)
      XCTAssertEqual("[1:5, 1:6] IDENTIFIER: f", symbols[1].description)
      XCTAssertEqual("[1:7, 1:8] ASSIGN: =", symbols[2].description)
      XCTAssertEqual("[1:9, 1:11] INT_CONST: 10", symbols[3].description)
      XCTAssertEqual("[1:11, 1:12] SEMICOLON: ;", symbols[4].description)
      XCTAssertEqual("[1:12, 1:13] EOF: $", symbols[5].description)
    }
    
    symbols = generateSymbols("val x: int;")
    XCTAssertEqual(6, symbols.count)
    if symbols.count == 6 {
      XCTAssertEqual("[1:1, 1:4] VAL: val", symbols[0].description)
      XCTAssertEqual("[1:5, 1:6] IDENTIFIER: x", symbols[1].description)
      XCTAssertEqual("[1:6, 1:7] COLON: :", symbols[2].description)
      XCTAssertEqual("[1:8, 1:11] IDENTIFIER: int", symbols[3].description)
      XCTAssertEqual("[1:11, 1:12] SEMICOLON: ;", symbols[4].description)
      XCTAssertEqual("[1:12, 1:13] EOF: $", symbols[5].description)
    }
  }
  
  func testExpressionsInMultipleLines() {
    let symbols = generateSymbols("""
let x = 10;
x = 20
""")
    XCTAssertEqual(9, symbols.count)
    guard symbols.count == 9 else { return }
    XCTAssertEqual("[1:1, 1:4] LET: let", symbols[0].description)
    XCTAssertEqual("[1:5, 1:6] IDENTIFIER: x", symbols[1].description)
    XCTAssertEqual("[1:7, 1:8] ASSIGN: =", symbols[2].description)
    XCTAssertEqual("[1:9, 1:11] INT_CONST: 10", symbols[3].description)
    XCTAssertEqual("[1:11, 1:12] SEMICOLON: ;", symbols[4].description)
    XCTAssertEqual("[2:1, 2:2] IDENTIFIER: x", symbols[5].description)
    XCTAssertEqual("[2:3, 2:4] ASSIGN: =", symbols[6].description)
    XCTAssertEqual("[2:5, 2:7] INT_CONST: 20", symbols[7].description)
    XCTAssertEqual("[2:7, 2:8] EOF: $", symbols[8].description)
  }

  func testMultiLineComment() {
    var symbols = generateSymbols("""
(*
dweldklwed
dwledklwd
lwedklwe
*)
""")
    XCTAssertEqual(1, symbols.count)
    XCTAssertEqual(TokenType.eof, symbols[0].tokenType)
    
    symbols = generateSymbols("""
val x = 10;
(*
dweldklwed
dwledklwd
lwedklwe
*)

val x = 20.15;
""")
    XCTAssertEqual(11, symbols.count)
    guard symbols.count == 11 else { return }
    XCTAssertEqual(TokenType.keywordVal, symbols[0].tokenType)
    XCTAssertEqual(TokenType.identifier, symbols[1].tokenType)
    XCTAssertEqual(TokenType.assign, symbols[2].tokenType)
    XCTAssertEqual(TokenType.integerConstant, symbols[3].tokenType)
    XCTAssertEqual(TokenType.semicolon, symbols[4].tokenType)
    XCTAssertEqual(TokenType.keywordVal, symbols[5].tokenType)
    XCTAssertEqual(TokenType.identifier, symbols[6].tokenType)
    XCTAssertEqual(TokenType.assign, symbols[7].tokenType)
    XCTAssertEqual(TokenType.floatingConstant, symbols[8].tokenType)
    XCTAssertEqual(TokenType.semicolon, symbols[9].tokenType)
    XCTAssertEqual(TokenType.eof, symbols[10].tokenType)
  }
  
  func testIdentifier() {
    XCTAssertEqual(TokenType.identifier, generateSymbols("ident1").first?.tokenType)
    XCTAssertEqual("ident1", generateSymbols("ident1").first?.lexeme)
    
    XCTAssertEqual(TokenType.integerConstant, generateSymbols("1ident").first?.tokenType)
    XCTAssertEqual("ident", generateSymbols("1ident")[1].lexeme)
    XCTAssertEqual(TokenType.integerConstant, generateSymbols("1ident").first?.tokenType)
    
    XCTAssertEqual("abc_", generateSymbols("abc_")[0].lexeme)
    XCTAssertEqual(TokenType.identifier, generateSymbols("abc_")[0].tokenType)
    
    XCTAssertEqual(TokenType.identifier, generateSymbols("a'a").first?.tokenType)
    XCTAssertEqual("a'a", generateSymbols("a'a").first?.lexeme)
    
    XCTAssertEqual(TokenType.identifier, generateSymbols("#&#?@").first?.tokenType)
    XCTAssertEqual("#&#?@", generateSymbols("#&#?@").first?.lexeme)
    
    XCTAssertEqual(TokenType.identifier, generateSymbols("!%&$#+-/:<=>?@\\~‘^|*").first?.tokenType)
    XCTAssertEqual("!%&$#+-/:<=>?@\\~‘^|*", generateSymbols("!%&$#+-/:<=>?@\\~‘^|*").first?.lexeme)
    
    XCTAssertEqual(3, generateSymbols("ident@#").count)
    
    XCTAssertEqual("[1:1, 1:3] IDENTIFIER: &&", generateSymbols("&&").first?.description)
    
    // TODO: -
    XCTAssertEqual("[1:1, 1:3] IDENTIFIER: ==", generateSymbols("==").first?.description)
    XCTAssertEqual("[1:1, 1:3] IDENTIFIER: ||", generateSymbols("||").first?.description)
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
    var symbols = generateSymbols("true = false")
    XCTAssertEqual(4, symbols.count)
    XCTAssertEqual("[1:1, 1:5] LOG_CONST: true", symbols[0].description)
    XCTAssertEqual("[1:6, 1:7] ASSIGN: =", symbols[1].description)
    XCTAssertEqual("[1:8, 1:13] LOG_CONST: false", symbols[2].description)
    XCTAssertEqual("[1:13, 1:14] EOF: $", symbols[3].description)
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
