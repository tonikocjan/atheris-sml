//
//  LexAn.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//

import Foundation

protocol LexicalAnalyzer: Sequence {
  func nextSymbol() throws -> Symbol
}
