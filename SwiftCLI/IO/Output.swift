//
//  Output.swift
//  Example
//
//  Created by Jake Heiser on 12/14/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

func printError(error: String) {
    printError(error, terminator: "\n")
}

func printError(error: String, terminator: String) {
    let handle = NSFileHandle.fileHandleWithStandardError()
    let fullString = error + terminator
    if let errorData = fullString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        handle.writeData(errorData)
    } else {
        print(error)
    }
}