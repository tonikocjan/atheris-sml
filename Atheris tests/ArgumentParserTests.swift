//
//  ArgumentParserTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 25/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

@testable import Atheris
import XCTest

class ArgumentParserTests: XCTestCase {
  func testEmptyArgs() {
    let parser = ArgumentParser()
    parser.parseArguments([])
    XCTAssertEqual(0, parser.count)
  }
  
  func testRandomArgs() {
    let parser = ArgumentParser()
    parser.parseArguments(["/Users/toni/swift/Atheris/main.swift", "main.ar", "dump_lex=true", "dump_ast=false", "phase=lexan", "stack_size=999"])
    
    XCTAssertEqual(6, parser.count)
    
    XCTAssertEqual("main.ar", parser.string(for: "source_file"))
    XCTAssertEqual(999, parser.int(for: "stack_size"))
    XCTAssertEqual("lexan", parser.string(for: "phase"))
    XCTAssertTrue(parser.bool(for: "dump_lex") ?? false)
    XCTAssertFalse(parser.bool(for: "dump_ast") ?? true)
    
    XCTAssertNil(parser.bool(for: "no_such_key"))
    XCTAssertNil(parser.string(for: "no_such_key"))
    XCTAssertNil(parser.int(for: "no_such_key"))
  }
}
