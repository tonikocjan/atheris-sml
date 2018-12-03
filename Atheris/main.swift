//
//  main.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

do {
  try Atheris(argumentParser: ArgumentParser())
    .parseArguments(CommandLine.arguments)
    .compile()
} catch {
  let errorMessage = (error as? AtherisError)?.errorMessage ?? error.localizedDescription
  LoggerFactory.logger.error(message: errorMessage)
}
