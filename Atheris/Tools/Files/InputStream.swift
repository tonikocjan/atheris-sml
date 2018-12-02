//
//  InputStream.swift
//  Atheris
//
//  Created by Toni Kocjan on 07/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol InputStream {
  func next() throws -> Character
}
