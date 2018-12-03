//
//  SyntaxParserTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

//@testable import Atheris
import XCTest

class SyntaxParserTests: XCTestCase {
  func testAst1() {
    let code = """
val x = 10
"""
    let lexan = LexAn(inputStream: TextStream(string: code))
    let parser = SynAn(lexan: lexan)
    
    
  }
}

private extension SyntaxParserTests {
  
}
