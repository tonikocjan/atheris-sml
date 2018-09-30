//
//  main.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

do {
//  try Atheris(argumentParser: ArgumentParser())
//    .parseArguments(CommandLine.arguments)
//    .compile()
  
  let reader = try FileReader(fileUrl: URL(string: "/Users/tonikocjan/swift/Atheris/Atheris/playground.ar")!)
  defer { reader.closeFile() }
  while let line = reader.readLine() {
    print(line)
  }
} catch {
  LoggerFactory.logger.error(message: error.localizedDescription)
}
