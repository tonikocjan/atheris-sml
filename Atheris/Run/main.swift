//
//  main.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

do {
  let parser = ArgumentParser()
  parser.parseArguments(CommandLine.arguments)
  
  guard let sourceFile = parser.string(for: ArgumentParser.Arguments.sourceFile.rawValue) else {
    throw Atheris.Error.invalidArguments(errorMessage: "Source file missing!")
  }
  guard let url = URL(string: sourceFile) else {
    throw Atheris.Error.invalidPath(sourceFile)
  }
  
  let fileReader = try FileReader(fileUrl: url)
  let inputStream = FileInputStream(fileReader: fileReader)
  
  try Atheris(inputStream: inputStream).compile()
} catch {
  let errorMessage = (error as? AtherisError)?.errorMessage ?? error.localizedDescription
  LoggerFactory.logger.error(message: errorMessage)
}
