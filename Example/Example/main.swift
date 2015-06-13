//
//  main.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import Foundation

CLI.setup(name: "baker", description: "Baker - your own personal baker, here to bake you whatever you desire.")

CLI.registerChainableCommand(commandName: "init")
    .withShortDescription("Creates a Bakefile in the current or given directory")
    .withSignature("[<directory>]")
    .withExecutionBlock {(arguments) in
        let givenDirectory = arguments.optionalArgument("directory")
        
        let fileName = givenDirectory?.stringByAppendingPathComponent("Bakefile") ?? "./Bakefile"
        
        let dict = ["items": []]
        let json = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
        //        json.
        //        if NSFileManager.defaultManager().createFileAtPath(fileName, contents: , attributes: nil) {
        //            return success()
        //        } else {
        //            return failure("The Bakefile was not able to be created")
        //        }
}

CLI.registerCommand(BakeCommand())

CLI.registerCommand(RecipeCommand())

func createListCommand() -> CommandType {
    let listCommand = LightweightCommand(commandName: "list")
    //    listCommand.commandShortDescription = "Lists some possible items the baker can bake for you."
    //
    //    var showExoticFoods = false
    //    listCommand.handleFlags(["-e", "--exotics-included"], usage: "Include exotic foods in the list of items baker can bake you") {(flag) in
    //        showExoticFoods = true
    //    }
    //
    //    listCommand.lightweightExecutionBlock = {(arguments, options) in
    //        var foods = ["bread", "cookies", "cake"]
    //        if showExoticFoods {
    //            foods += ["exotic baker item 1", "exotic baker item 2"]
    //        }
    //        println("Items that baker can bake for you:")
    //        for i in 0..<foods.count {
    //            println("\(i+1). \(foods[i])")
    //        }
    //        return success()
    //    }
    return listCommand
}

CLI.registerCommand(createListCommand())

let result = CLI.debugGoWithArgumentString("baker bake cake")

func cliExit(result: CLIResult) {
    exit(result)
}

cliExit(result) // Get around Swift warning
