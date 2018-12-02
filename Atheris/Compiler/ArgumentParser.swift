//
//  ArgumentParser.swift
//  Atheris
//
//  Created by Toni Kocjan on 25/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol ArgumentParserProtocol {
  func parseArguments(_ arguments: [String])
  func bool(for key: String) -> Bool?
  func string(for key: String) -> String?
  func int(for key: String) -> Int?
  var count: Int { get }
}

class ArgumentParser: ArgumentParserProtocol {
  private var arguments = [String: String]()
  
  func parseArguments(_ arguments: [String]) {
    guard arguments.count >= 2 else { return }
    self.arguments[Arguments.workingDirectory.rawValue] = arguments[0]
    self.arguments[Arguments.sourceFile.rawValue] = arguments[1]
    arguments
      .dropFirst()
      .compactMap(parseArgument)
      .forEach { self.arguments[$0.key] = $0.value }
  }
  
  func bool(for key: String) -> Bool? {
    guard let stringValue = arguments[key], let bool = Bool(stringValue) else { return nil }
    return bool
  }
  
  func string(for key: String) -> String? {
    return arguments[key]
  }
  
  func int(for key: String) -> Int? {
    guard let stringValue = arguments[key], let int = Int(stringValue) else { return nil }
    return int
  }
  
  var count: Int {
    return arguments.count
  }
}

extension ArgumentParser {
  enum Arguments: String {
    case sourceFile = "source_file"
    case workingDirectory = "working_dir"
  }
}

private extension ArgumentParser {
  func parseArgument(_ argument: String) -> (key: String, value: String)? {
    let splitted = argument.split(separator: "=").map { String($0) }
    guard splitted.count == 2 else { return nil }
    return (key: splitted[0],
            value: splitted[1])
  }
}
