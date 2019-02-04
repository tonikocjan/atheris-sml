// swift-tools-version:4.0
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
    products: [
        .library(name: "AtherisSML", targets: ["Atheris"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Atheris",
            dependencies: [],
            path: "Atheris")
    ]
)