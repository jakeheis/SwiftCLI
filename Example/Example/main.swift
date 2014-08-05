//
//  main.swift
//  Example
//
//  Created by Jake Heiser on 7/31/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

CLI.setup(name: "greeter", version: "1.0", description: "Greeter - your own personal greeter")
//CLI.registerChainableCommand(commandName: "greet")
//    .withShortDescription("Greets the given person")
//    .withSignature("<person>")
//    .withExecutionBlock({arguments, options in
//        let person = arguments["person"] as String
//        println("Hey there, \(person)!")
//        return .Success
//    })
//
//let greetCommand = LightweightCommand(commandName: "greet")
//greetCommand.lightweightCommandShortDescription = "Greets the given person"
//greetCommand.lightweightCommandSignature = "<person>"
//greetCommand.lightweightExecutionBlock = {arguments, options in
//    let person = arguments["person"] as String
//    println("Hey there, \(person)!")
//    return .Success
//}



class GreetCommand: Command {
    
    private var numberOfTimes = 1
    private var loudly = false
    
    
    override func commandName() -> String  {
        return "greet"
    }
    
    override func commandShortDescription() -> String  {
        return "Greets the given person"
    }
    
    override func commandSignature() -> String  {
        return "<person>"
    }
    
    override func handleOptions()  {
        self.onFlags(["-l", "--loudly"], block: {flag in
            self.loudly = true
        }, usage: "Makes the the greeting be said loudly")
        
        self.onKeys(["-n", "--number-of-times"], block: {key, value in
            if let times = value.toInt() {
                self.numberOfTimes = times
            }
        }, usage: "Makes the greeter greet a certain number of times", valueSignature: "numberOfTimes")
    }
    
    override func execute() -> CommandResult  {
        let person = self.arguments["person"] as String
        for _ in 1...self.numberOfTimes {
            var str = "Hey there, \(person)!"
            if self.loudly {
                str = str.uppercaseString
            }
            println(str)
        }
        return .Success
    }
}
CLI.registerCommand(GreetCommand())

CLI.debugGoWithArgumentString("greeter greet Jack -l --number-of-times 5")

//CLI.setup(name: "baker", description: "Baker, your own personal cook, here to bake you whatever you desire.")
//
//CLI.registerChainableCommand(commandName: "init")
//    .withShortDescription("Creates a Bakefile in the current or given directory")
//    .withSignature("[<directory>]")
//    .withExecutionBlock({arguments, options in
//        let givenDirectory = arguments["directory"] as String?
//        
//        let fileName = givenDirectory ? givenDirectory!.stringByAppendingPathComponent("Bakefile") : "./Bakefile"
//        
//        let dict = ["items": []]
//        let success = NSFileManager.defaultManager().createFileAtPath(fileName, contents: NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted, error: nil), attributes: nil)
//        if success {
//            return .Success
//        } else {
//            return .Failure("The Bakefile was not able to be created")
//        }
//    })
//
//
//let listCommand = LightweightCommand(commandName: "list")
//listCommand.lightweightCommandShortDescription = "Lists the possible things baker can bake for you."
//
//var showExoticFoods = false
//listCommand.handleFlags(["-e", "--exotics-included"], block: {flag in
//    showExoticFoods = true
//}, usage: "Include exotic foods in the list of items baker can bake you")
//
//listCommand.lightweightExecutionBlock = {arguments, options in
//    var foods = ["bread", "cookies", "cake"]
//    if showExoticFoods {
//        foods += ["exotic baker item 1", "exotic baker item 2"]
//    }
//    println("Items that baker can bake for you:")
//    for i in 0..<foods.count {
//        println("\(i+1). \(foods[i])")
//    }
//    return .Success
//}
//CLI.registerCommand(listCommand)
//
//let bakerCommand = BakeCommand()
//CLI.registerCommand(bakerCommand)
//
////CLI.registerDefaultCommand(bakerCommand)
//
//CLI.go()
