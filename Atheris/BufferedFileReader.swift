//
//  BufferedFileReader.swift
//  Atheris
//
//  Created by Toni Kocjan on 01/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class BufferedFileReader: FileReaderProtocol {
  private let fileReader: FileReaderProtocol
  let bufferSize: Int
  
  ///
  private var buffer: Data?
  private var offset = 0
  var read = 0
  ///
  
  required init(fileUrl url: URL) throws {
    self.fileReader = try FileReader(fileUrl: url)
    self.bufferSize = 1024
  }
  
  init(fileUrl url: URL, bufferSize: Int) throws {
    self.fileReader = try FileReader(fileUrl: url)
    self.bufferSize = bufferSize
  }
  
  init(fileReader: FileReaderProtocol, bufferSize: Int) {
    self.fileReader = fileReader
    self.bufferSize = bufferSize
  }
  
  func closeFile() {
    fileReader.closeFile()
  }
  
  func readByte() -> Data {
    read += 1
    if let buffer = buffer {
      guard offset < buffer.count else { return Data() }
      let byte = buffer.subdata(in: offset..<offset + 1)
      offset += 1
      if buffer.count - offset == 0 { self.buffer = nil }
      return byte
    }
    let data = fileReader.readBytes(count: bufferSize)
    self.buffer = data
    self.offset = 0
    return readByte()
  }
  
  func readBytes(count: Int) -> Data {
    if let buffer = buffer {
      let available = min(count, buffer.count - offset)
      let bytes = buffer.subdata(in: offset..<available)
      offset += available
      if buffer.count - offset == 0 { self.buffer = nil }
      return bytes
    }
    let data = fileReader.readBytes(count: bufferSize)
    self.buffer = data
    self.offset = 0
    return readBytes(count: count)
  }
  
  func readChar() throws -> Character {
    guard let char = readByte().first else { throw FileReader.Error.fileEmpty }
    return Character(UnicodeScalar(char))
  }
  
  func readLine() -> String? {
    var line = ""
    do {
      var char = try readChar()
      while char != "\n" {
        line += "\(char)"
        char = try readChar()
      }
      return line
    } catch {
      return line.isEmpty ? nil : line
    }
  }
  
  func readString(size: Int) -> String? {
    var string = ""
    while true {
      let bytes = readBytes(count: size)
      guard let str = String(data: bytes, encoding: .utf8) else { continue }
      string += str
      if bytes.isEmpty || string.count == size { break }
    }
    return string
  }
}
