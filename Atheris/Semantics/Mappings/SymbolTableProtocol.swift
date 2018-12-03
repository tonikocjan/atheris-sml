//
//  SymbolTableProtocol.swift
//  Atheris
//
//  Created by Toni Kocjan on 03/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol SymbolTableProtocol {
  func newScope()
  func oldScope()
  func addBindingToCurrentScope(name: String, binding: AstBinding) throws
  func removeBindingFromCurrentScope(name: String) throws
  func findBinding(name: String) -> AstBinding?
}
