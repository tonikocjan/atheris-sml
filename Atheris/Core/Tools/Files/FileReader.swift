//
//  FileReader.swift
//  Atheris
//
//  Created by Toni Kocjan on 30/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol FileReaderProtocol {
  init(fileUrl url: URL) throws
  func closeFile()
  func readByte() -> Data
  func readBytes(count: Int) -> Data
  func readChar() throws -> Character
  func readLine() -> String?
  func readString(size: Int) -> String?
  func readLines() -> [String]
}

public class FileReader: FileReaderProtocol {
  private let fileHandle: FileHandle
  
  public required init(fileUrl url: URL) throws {
    self.fileHandle = try FileHandle(forReadingFrom: url)
  }
  
  public func closeFile() {
    self.fileHandle.closeFile()
  }
  
  public func readByte() -> Data {
    return fileHandle.readData(ofLength: 1)
  }
  
  public func readBytes(count: Int) -> Data {
    return fileHandle.readData(ofLength: count)
  }
  
  public func readChar() throws -> Character {
    guard let char = readByte().first else { throw Error.fileEmpty }
    return Character(UnicodeScalar(char))
  }
  
  public func readLine() -> String? {
    var line = ""
    do {
      var char = try readChar()
      while char != "\n" {
        line.append(char)
        char = try readChar()
      }
      return line
    } catch {
      return line.isEmpty ? nil : line
    }
  }
  
  public func readString(size: Int) -> String? {
    return String(data: readBytes(count: size), encoding: .utf8)
  }
  
  public func readLines() -> [String] {
    var lines = [String]()
    while let line = readLine() {
      lines.append(line)
    }
    return lines
  }
}

public extension FileReader {
  public enum Error: Swift.Error {
    case fileEmpty
  }
}
