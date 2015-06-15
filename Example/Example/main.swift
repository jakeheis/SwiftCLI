//
//  main.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import Foundation

CLI.setup(name: "baker", version: "1.1", description: "Baker - your own personal baker, here to bake you whatever you want")

// MARK: - ChainableCommand example

CLI.registerChainableCommand(commandName: "init")
    .withShortDescription("Creates a Bakefile in the current or given directory")
    .withSignature("[<directory>]")
    .withOptionsSetup {(command, options) in
        command.addDefaultHelpFlag(options)
    }
    .withExecutionBlock {(arguments) in
        let givenDirectory = arguments.optionalArgument("directory")
        
        let path = givenDirectory?.stringByAppendingPathComponent("Bakefile") ?? "./Bakefile"
        
        do {
           try Bakefile.create(path: path)
        } catch {
            throw CLIError.Error("The Bakefile was not able to be created")
        }
    }

// MARK: - CommandType examples

CLI.registerCommand(BakeCommand())

CLI.registerCommand(RecipeCommand())

// MARK: - LightweightCommand example

func createListCommand() -> CommandType {
    let listCommand = LightweightCommand(commandName: "list")
    listCommand.commandShortDescription = "Lists some possible items the baker can bake for you."
    
    var showExoticFoods = false
    
    listCommand.optionsSetupBlock = {(command, options) in
        options.onFlags(["-e", "--exotics-included"]) {(flag) in
            showExoticFoods = true
        }
        command.addDefaultHelpFlag(options)
    }
    
    listCommand.executionBlock = {(arguments) in
        var foods = ["bread", "cookies", "cake"]
        
        if showExoticFoods {
            foods += ["exotic baker item 1", "exotic baker item 2"]
        }
        
        print("Items that baker can bake for you:")
        
        for i in 0..<foods.count {
            print("\(i+1). \(foods[i])")
        }
    }
    return listCommand
}

CLI.registerCommand(createListCommand())

// MARK: - Go

let result = CLI.go()
exit(result)
