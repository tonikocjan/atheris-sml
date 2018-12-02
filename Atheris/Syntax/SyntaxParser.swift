//
//  SyntaxParser.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol SyntaxParser {
  var lexan: LexicalAnalyzer { get }
  func parse() throws -> AstBindings
}
