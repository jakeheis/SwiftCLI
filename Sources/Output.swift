//
//  Output.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 12/14/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public func printError(_ error: String) {
    printError(error, terminator: "\n")
}

public func printError(_ error: String, terminator: String) {
    let handle = FileHandle.standardError
    let fullString = error + terminator
    if let errorData = fullString.data(using: .utf8, allowLossyConversion: false) {
        handle.write(errorData)
    } else {
        print(error)
    }
}
