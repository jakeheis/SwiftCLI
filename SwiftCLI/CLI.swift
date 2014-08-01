//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

let router = Router()

var strictOnOptions = true

class CLI: NSObject {
    
    class func registerCommands(commands: [Command]) {
        for command in commands {
            self.registerCommand(command)
        }
    }
    
    class func registerCommand(command: Command) {
        router.commands += command;
    }
    
    class func registerChainableCommand(#commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        router.commands += chainable
        return chainable
    }
    
    
    class func registerCustomHelpCommand(helpCommand: HelpCommand) {
        router.helpCommand = helpCommand
    }
    
    class func registerVersionForVersionCommand(version: String) {
        router.versionComand = ChainableCommand(commandName: "version")
            .withShortDescription("Prints the current version of this app")
            .allowAllFlagsAndOptions()
            .onExecution({params, options in
                println("Version: \(version)")
                return (true, nil)
            })
    }
    
    class func go() -> Bool {
        var args = NSProcessInfo.processInfo().arguments as [String]
        
        let (commandTry, arguments, options) = router.route(arguments: args)
        
        if let command = commandTry {
            
            let parser = SignatureParser(signature: command.commandSignature(), arguments: arguments)
            let (namedArguments, errorString) = parser.parse()
            
            if !namedArguments {
                println(errorString!)
                return false
            }
            
            command.prepForExecution(namedArguments!, options: options)
           
            if !command.optionsAccountedFor() && strictOnOptions {
                println(command.options.unaccountedForMessage())
                return false
            }
            
            let (success, error) = command.execute()

            if !success {
                println(error!)
                return false
            }
            
            return true
        } else {
            println("Command not found")
            return false
        }
    }
    
}
