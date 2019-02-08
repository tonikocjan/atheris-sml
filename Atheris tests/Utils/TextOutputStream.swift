//
//  TextOutputStream.swift
//  Atheris tests
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class TextOutputStream: OutputStream {
  private(set) var buffer = ""
  
  public func print(_ string: String) {
    buffer.append(string)
  }
  
  public func printLine(_ string: String) {
    buffer.append(string + "\n")
  }
}
