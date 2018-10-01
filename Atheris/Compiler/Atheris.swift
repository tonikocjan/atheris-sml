//
//  Atheris.swift
//  Atheris
//
//  Created by Toni Kocjan on 25/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class Atheris {
  let argumentParser: ArgumentParserProtocol
  
  init(argumentParser: ArgumentParserProtocol) {
    self.argumentParser = argumentParser
  }
  
  func parseArguments(_ args: [String]) -> Atheris {
    argumentParser.parseArguments(args)
    return self
  }
  
  func compile() throws {
    guard let sourceFile = argumentParser.string(for: Arguments.sourceFile.rawValue) else {
      throw Error.invalidArguments(errorMessage: "Source file missing!")
    }
    
    LoggerFactory.logger.log(message: "Compiling \(sourceFile) ... ")
    
    let lexan = try LexAn(parseFile: sourceFile)
    
  }
}

extension Atheris {
  enum Error: Swift.Error {
    case invalidArguments(errorMessage: String)
    
    var localizedDescription: String {
      switch self {
      case .invalidArguments(let errMessage):
        return errMessage
      }
    }
  }
}
