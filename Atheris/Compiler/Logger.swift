//
//  Logger.swift
//  Atheris
//
//  Created by Toni Kocjan on 29/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol LoggerProtocol {
  func log(message: String)
  func error(message: String)
  func warning(message: String)
}

class Logger: LoggerProtocol {
  func log(message: String) {
    print(message)
  }
  
  func error(message: String) {
    print("❗️ " + message)
  }
  
  func warning(message: String) {
    print("⚠ " + message)
  }
}

class LoggerFactory {
  static let logger: LoggerProtocol = Logger()
}
