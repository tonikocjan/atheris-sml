//
//  DefaultDict.swift
//  Atheris
//
//  Created by Toni Kocjan on 18/10/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

struct Counter<Key: Hashable, Value> {
  private var internalStorage: Dictionary<Key, Value> = .init()
  private let increment: (Value) -> Value
  private let defaultValue: () -> Value
}

extension Counter {
  subscript(_ key: Key) -> Value {
    get {
      return internalStorage[key] ?? defaultValue()
    }
    set {
      if internalStorage[key] != nil {
        print()
      }
      internalStorage[key] = increment(self[key])
    }
  }
  
  func description() -> String {
    return internalStorage.description
  }
}

extension Counter where Value == Int {
  init() {
    increment = { $0 + 1 }
    defaultValue = { 0 }
  }
}
