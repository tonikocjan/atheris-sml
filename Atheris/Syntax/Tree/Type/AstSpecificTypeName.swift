//
//  AstSpecificTypeName.swift
//  Atheris
//
//  Created by Toni Kocjan on 12/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

class AstSpecificTypeName: AstTypeName {
  let type: AstType
  
  init(position: Position, name: String, type: AstType) {
    self.type = type
    super.init(position: position, name: name)
  }
}
