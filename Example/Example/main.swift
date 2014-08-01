//
//  main.swift
//  Example
//
//  Created by Jake Heiser on 7/31/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

CLI.registerChainableCommand(commandName: "init")
    .withShortDescription("Creates a Bakefile in the current or given directory")
    .withSignature("[<directory>]")
    .onExecution({arguments, options in
        let givenDirectory = arguments["directory"] as String?
        
        let fileName = givenDirectory ? givenDirectory!.stringByAppendingPathComponent("Bakefile") : "./Bakefile"
        
        let dict = ["items": []]
        let success = NSFileManager.defaultManager().createFileAtPath(fileName, contents: NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted, error: nil), attributes: nil)
        let message: String? = success ? nil : "The Bakefile was not able to be created"
        return (success, message)
    })


let exoticFlags = ["-e", "--exotics-included"]
let listCommand = LightweightCommand(commandName: "list")
listCommand.lightweightCommandShortDescription = "Lists the possible things baker can bake for you."
listCommand.lightweightAcceptableFlags = exoticFlags
listCommand.lightweightExecutionBlock = {arguments, options in
    var foods = ["bread", "cookies", "cake"]
    options.onFlags(exoticFlags, block: {flag in
        foods += ["exotic baker item 1", "exotic baker item 2"]
    })
    println("Items that baker can bake for you:")
    for i in 0..<foods.count {
        println("\(i+1). \(foods[i])")
    }
    return (true, nil)
}
CLI.registerCommand(listCommand)

let bakerCommand = BakeCommand.command()
CLI.registerCommand(bakerCommand)
CLI.registerDefaultCommand(bakerCommand)

CLI.go()
