//
//  BufferedReaderTests.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 01/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

@testable import Atheris
import XCTest

class BufferedReaderTests: XCTestCase {
  let bufferSizes = [1, 64, 1024, 10000]
  
  func testReadCharByChar() {
    do {
      let path = "/Users/tonikocjan/swift/Atheris/Atheris tests/Lexan/file_reader_test_1".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
      for size in bufferSizes {
        let fileReader = try BufferedFileReader(fileUrl: URL(string: path)!, bufferSize: size)
        XCTAssertEqual("H", try fileReader.readChar())
        XCTAssertEqual("e", try fileReader.readChar())
        XCTAssertEqual("l", try fileReader.readChar())
        XCTAssertEqual("l", try fileReader.readChar())
        XCTAssertEqual("o", try fileReader.readChar())
        XCTAssertEqual(" ", try fileReader.readChar())
        XCTAssertEqual("A", try fileReader.readChar())
        XCTAssertEqual("t", try fileReader.readChar())
        XCTAssertEqual("h", try fileReader.readChar())
        XCTAssertEqual("e", try fileReader.readChar())
        XCTAssertEqual("r", try fileReader.readChar())
        XCTAssertEqual("i", try fileReader.readChar())
        XCTAssertEqual("s", try fileReader.readChar())
        XCTAssertEqual("!", try fileReader.readChar())
        XCTAssertEqual("\n", try fileReader.readChar())
        XCTAssertEqual(":", try fileReader.readChar())
        XCTAssertEqual(")", try fileReader.readChar())
        XCTAssertNil(try? fileReader.readChar())
      }
    } catch {
      XCTFail()
    }
  }
  
  func testReadLineByLine() {
    do {
      let path = "/Users/tonikocjan/swift/Atheris/Atheris tests/Lexan/file_reader_test_2".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
      for size in bufferSizes {
        let fileReader = try BufferedFileReader(fileUrl: URL(string: path)!, bufferSize: size)
        XCTAssertEqual("line1", fileReader.readLine())
        XCTAssertEqual("line2", fileReader.readLine())
        XCTAssertEqual("line3", fileReader.readLine())
        XCTAssertEqual("", fileReader.readLine())
        XCTAssertEqual("line4", fileReader.readLine())
        XCTAssertNil(fileReader.readLine())
      }
    } catch {
      XCTFail()
    }
  }
  
  func testReadBytes() {
    do {
      let path = "/Users/tonikocjan/swift/Atheris/Atheris tests/Lexan/file_reader_test_1".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
      for size in bufferSizes {
        let fileReader = try BufferedFileReader(fileUrl: URL(string: path)!, bufferSize: size)
        let bytes = fileReader.readString(size: 1000) ?? "" // NOTE: - try to read more bytes than the file contains
        XCTAssertEqual(17, bytes.count)
        XCTAssertEqual("Hello Atheris!\n:)", bytes)
      }
    } catch {
      XCTFail()
    }
  }
  
  func testPerformance() {
    self.measure {
      do {
        let path = "/Users/tonikocjan/swift/Atheris tests/Lexan/"
          .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let fileReader = try BufferedFileReader(fileUrl: URL(string: path)!, bufferSize: 1024)
        while let _ = fileReader.readLine() {}
        print()
      } catch {
        XCTFail()
      }
    }
  }
}
