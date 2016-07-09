//
//  Output.swift
//  Example
//
//  Created by Jake Heiser on 12/14/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

func printError(_ error: String) {
    printError(error, terminator: "\n")
}

func printError(_ error: String, terminator: String) {
    let handle = FileHandle.withStandardError
    let fullString = error + terminator
    if let errorData = fullString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
        handle.write(errorData)
    } else {
        print(error)
    }
}
