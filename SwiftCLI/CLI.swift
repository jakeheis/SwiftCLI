//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

let router = Router()

var CLIName = "" // Transition to class variable once available

class CLI: NSObject {

    class func setup(#name: String) {
        self.setup(name: name, version: "1.0")
    }
    
    class func setup(#name: String, version: String) {
        CLIName = name
        
        if router.versionComand {
            router.versionComand!.version = version
        }
    }
    
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
    
    class func registerCustomVersionCommand(versionCommand: VersionCommand) {
        router.versionComand = versionCommand
    }
    
    class func registerDefaultCommand(command: Command) {
        router.defaultCommand = command
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
           
            if !command.optionsAccountedFor() {
                let message = command.options.unaccountedForMessage(command: command)
                println(message)
                if (command.failOnUnhandledOptions()) {
                    return false
                }
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
