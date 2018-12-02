//
//  FileWriter.swift
//  Atheris
//
//  Created by Toni Kocjan on 07/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol FileWriterProtocol {
  init(fileUrl url: URL) throws
  func closeFile()
  func writeChar(_ char: Character)
  func writeString(_ string: String)
  func writeLine(_ string: String)
  func writeData(_ data: Data)
}

class FileWriter: FileWriterProtocol {
  private let fileHandle: FileHandle
  
  required init(fileUrl url: URL) throws {
    FileManager.default.createFile(atPath: url.absoluteString,
                                   contents: nil,
                                   attributes: nil)
    self.fileHandle = try FileHandle(forWritingTo: url)
  }
  
  func closeFile() {
    fileHandle.closeFile()
  }
  
  func writeChar(_ char: Character) {
    writeString(char.description)
  }
  
  func writeString(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    writeData(data)
  }
  
  func writeLine(_ string: String) {
    writeString(string + "\n")
  }
  
  func writeData(_ data: Data) {
    fileHandle.write(data)
  }
}

extension FileWriter {
  enum Error: Swift.Error {
    case encodingError
  }
}
