//
//  Atheris.swift
//  Atheris
//
//  Created by Toni Kocjan on 25/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class Atheris {
  public var logger: LoggerProtocol = LoggerFactory.logger
  private let inputStream: InputStream
  
  public init(inputStream: InputStream) throws {
    self.inputStream = inputStream
  }
  
  public func compile() throws -> OutputStream {
    let symbolTable = SymbolTable(symbolDescription: SymbolDescription())
    var syntaxTree: AstBindings?
    
    do {
      logger.log(message: "SML -> Racket 🚀 [0.0.1 (pre-alpha)]:")
      let lexan = LexAn(inputStream: inputStream)
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
      
      
      
      // Execute racket
      #if os(Linux)
      // Code generation
      let codeGenerator = RacketCodeGenerator(outputStream: TextOutputStream(),
                                              configuration: .standard,
                                              symbolDescription: symbolTable.symbolDescription)
      try codeGenerator.visit(node: ast)
      return codeGenerator.outputStream
      #else
      
      // Code generation
      let treeGenerator = λcalculusGenerator(symbolDescription: symbolTable.symbolDescription)
      try treeGenerator.visit(node: ast)
      let codeGenerator = λcalculusCodeGen(outputStream: StdOutputStream(), mapping: treeGenerator.table)
      try codeGenerator.visit(node: ast)
      
//      let executor = Executor()
//      try executor.execute(file: "code.rkt")

      return codeGenerator.outputStream
      #endif
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

public extension Atheris {
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
