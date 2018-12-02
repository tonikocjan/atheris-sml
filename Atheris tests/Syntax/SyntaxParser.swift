//
//  SyntaxParser.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import XCTest

class SyntaxParser: XCTestCase {
  func testVariableBinding() {
    var lexan = LexAn(inputStream: TextStream(string: "val x = 10"))
    
  }
}
