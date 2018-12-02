//
//  FileInputStream.swift
//  Atheris
//
//  Created by Toni Kocjan on 06/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class FileInputStream: InputStream {
  let fileReader: FileReaderProtocol
  
  init(fileReader: FileReaderProtocol) {
    self.fileReader = fileReader
  }
  
  func next() throws -> Character {
    return try fileReader.readChar()
  }
}
