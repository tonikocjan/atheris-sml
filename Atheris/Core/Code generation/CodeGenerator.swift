//
//  CodeGenerator.swift
//  Atheris
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol CodeGenerator: AstVisitor {
  var outputStream: OutputStream { get }
}
