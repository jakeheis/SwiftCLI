//
//  Arguments.swift
//  Example
//
//  Created by Jake Heiser on 1/6/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation

class Arguments {
    
    let appName: String
    var commandName: String = ""
    var argumentsArray: [String]
    
    init() {
        let args = NSProcessInfo.processInfo().arguments as [String]
        appName = args[0]
        argumentsArray = Array(args[1..<args.count])
    }
    
    init(argumentString: String) {
        let args = argumentString.componentsSeparatedByString(" ")
        appName = args[0]
        argumentsArray = Array(args[1..<args.count])
    }
    
    func setFirstArgumentIsCommandName() {
        commandName = argumentsArray.first!
        argumentsArray.removeAtIndex(0)
    }
    
    var hasNoArguments: Bool {
        return argumentsArray.isEmpty
    }
    
    var firstArgument: String? {
        return argumentsArray.first
    }
    
    var firstArgumentIsFlag: Bool {
        return firstArgument?.hasPrefix("-") ?? false
    }
    
}