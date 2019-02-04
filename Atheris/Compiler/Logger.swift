//
//  Logger.swift
//  Atheris
//
//  Created by Toni Kocjan on 29/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol LoggerProtocol {
  func log(message: String)
  func error(message: String)
  func warning(message: String)
}

public class Logger: LoggerProtocol {
  public func log(message: String) {
    print(message)
  }
  
  public func error(message: String) {
    print("❗️ " + message)
  }
  
  public func warning(message: String) {
    print("⚠ " + message)
  }
}

public class LoggerFactory {
  public static let logger: LoggerProtocol = Logger()
}
