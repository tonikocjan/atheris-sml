//
//  FileOutputStream.swift
//  Atheris
//
//  Created by Toni Kocjan on 07/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class FileOutputStream: OutputStream {
  let fileWriter: FileWriterProtocol
  
  init(fileWriter: FileWriterProtocol) {
    self.fileWriter = fileWriter
  }
  
  func print(_ string: String) {
    fileWriter.writeLine(string)
  }
  
  func printLine(_ string: String) {
    fileWriter.writeLine(string)
  }
}
