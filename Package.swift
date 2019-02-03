//
//  Package.swift
//  Atheris
//
//  Created by Toni Kocjan on 25/01/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import PackageDescription

let package = Package(
  name: "AtherisSML",
  pkgConfig: nil,
  targets: [
    .target(
      name: "AtherisSML",
      dependencies: []),
    .testTarget(
      name: "Atheris tests",
      dependencies: ["AtherisSML"]),
    ]
  dependencies: []
)
