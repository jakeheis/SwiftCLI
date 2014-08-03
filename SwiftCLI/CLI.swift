//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

let router = Router()

var CLIName = "" // TODO: Transition to class variable once available
var CLIDescription = "" // TODO: Transition to class variable once available

class CLI: NSObject {
    
    class func setup(#name: String, version: String = "1.0", description: String = "") {
        CLIName = name
        
        if router.versionComand {
            router.versionComand!.version = version
        }
        
        CLIDescription = description
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
        
        let result = router.route(arguments: args)
        
        switch result {
        case let .Success(command, arguments, options, routedName):
            let parser = SignatureParser(signature: command.commandSignature(), arguments: arguments)
            let (namedArguments, errorString) = parser.parse()
            
            if !namedArguments {
                println(errorString!)
                return false
            }
            
            command.prepForExecution(namedArguments!, options: options)
            
            if !command.optionsAccountedFor() {
                if let message = command.options.unaccountedForMessage(command: command, routedName: routedName) {
                    println(message)
                }
                if (command.failOnUnhandledOptions()) {
                    return false
                }
            }
            
            if command.showingHelp {
                return true
            }
            
            let (success, error) = command.execute()
            
            if !success {
                println(error!)
                return false
            }
            
            return true
        case .Failure:
            println("Command not found")
            return false
        }
    }
    
}
