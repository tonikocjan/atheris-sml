//
//  main.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

let lexan = try? LexAn(parseFile: "playground.ar")
print(lexan?.nextSymbol())
