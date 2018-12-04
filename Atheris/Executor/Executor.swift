//
//  Executor.swift
//  Atheris
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol ExecutorProtocol {
  func execute(file: String) throws
}

class Executor: ExecutorProtocol {
  func execute(file: String) throws {
    print("Executing \(file) ...")
    
    let task = Process()
    task.arguments = [file]
    task.currentDirectoryPath = FileManager.default.currentDirectoryPath
    task.launchPath = "/Applications/Racket v7.1/bin/racket"
    task.launch()
    task.waitUntilExit()
    task.terminationHandler = {
      print("\nExecution ended with status: \($0.terminationStatus)")
    }
  }
}
