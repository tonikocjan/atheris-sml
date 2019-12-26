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
  private let stderr = FileHandle.standardError
  
  public func log(message: String) {
    stderr.write(message.data(using: .utf8)!)
  }
  
  public func error(message: String) {
    log(message: "❗️ " + message)
  }
  
  public func warning(message: String) {
    log(message: "⚠️ " + message)
  }
}

public class LoggerFactory {
  public static let logger: LoggerProtocol = Logger()
}
