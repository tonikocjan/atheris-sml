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
  var logger: LoggerProtocol = LoggerFactory.logger
  
  init(argumentParser: ArgumentParserProtocol) {
    self.argumentParser = argumentParser
  }
  
  func parseArguments(_ args: [String]) -> Atheris {
    argumentParser.parseArguments(args)
    return self
  }
  
  func compile() throws {
    let symbolTable = SymbolTable(symbolDescription: SymbolDescription())
    var syntaxTree: AstBindings?
    
    do {
      logger.log(message: "SML -> Racket 🚀 [0.0.1 (pre-alpha)]:")
      
      guard let sourceFile = argumentParser.string(for: ArgumentParser.Arguments.sourceFile.rawValue) else {
        throw Error.invalidArguments(errorMessage: "Source file missing!")
      }
      
      logger.log(message: "Compiling \(sourceFile) ... ")
      
      guard let url = URL(string: sourceFile) else { throw Error.invalidPath(sourceFile) }
      let fileReader = try FileReader(fileUrl: url)
      let lexan = LexAn(inputStream: FileInputStream(fileReader: fileReader))
      //    let outputStream = FileOutputStream(fileWriter: try FileWriter(fileUrl: URL(string: "lex")!))
      //    for symbol in lexan {
      //      outputStream.printLine(symbol.description)
      //    }
      
      // Parse syntax
      let synan = SynAn(lexan: lexan)
      let ast = try synan.parse()
      syntaxTree = ast
      
      // Name resolving
      let nameChecker = NameChecker(symbolTable: symbolTable,
                                    symbolDescription: symbolTable.symbolDescription)
      try nameChecker.visit(node: ast)
      
      // Type resolving
      let typeChecker = TypeChecker(symbolTable: symbolTable,
                                    symbolDescription: symbolTable.symbolDescription)
      try typeChecker.visit(node: ast)
      
      // Dump ast
      try dumpAst(ast: ast,
                  symbolDescription: symbolTable.symbolDescription)
      
      // Code generation
      let codeOutputStream = FileOutputStream(fileWriter: try FileWriter(fileUrl: URL(string: "code.rkt")!))
      let codeGenerator = RacketCodeGenerator(outputStream: codeOutputStream,
                                              configuration: .standard, symbolDescription: symbolTable.symbolDescription)
      try codeGenerator.visit(node: ast)
      
      // Execute racket
      let executor = Executor()
      try executor.execute(file: "code.rkt")
    } catch {
      if let syntaxTree = syntaxTree {
        try dumpAst(ast: syntaxTree,
                    symbolDescription: symbolTable.symbolDescription)
      }
      throw error
    }
  }
  
  private func dumpAst(ast: AstBindings, outputFile: String = "ast", symbolDescription: SymbolDescriptionProtocol) throws {
    let outputStream = FileOutputStream(fileWriter: try FileWriter(fileUrl: URL(string: outputFile)!))
    let dumpVisitor = DumpVisitor(outputStream: outputStream,
                                  symbolDescription: symbolDescription)
    try dumpVisitor.visit(node: ast)
  }
}

extension Atheris {
  enum Error: Swift.Error {
    case invalidPath(String)
    case fileNotFound(URL)
    case invalidArguments(errorMessage: String)
    
    var localizedDescription: String {
      switch self {
      case .invalidArguments(let errMessage):
        return errMessage
      case .invalidPath(let url):
        return "\(url) is not a valid URL!"
      case .fileNotFound:
        return "File not found or cannot be opened!"
      }
    }
  }
}
