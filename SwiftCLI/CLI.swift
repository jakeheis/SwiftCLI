//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class CLI: NSObject {
    
    // MARK: - Information
    
    struct CLIStatic {
        static var name = ""
        static var appVersion = "1.0"
        static var description = ""
        
        static var commands: [Command] = []
        static var helpCommand: HelpCommand? = HelpCommand.command()
        static var versionComand: VersionCommand? = VersionCommand.command()
        static var defaultCommand: Command = CLIStatic.helpCommand!
    }
    
    class func setup(#name: String, version: String = "1.0", description: String = "") {
        CLIStatic.name = name
        CLIStatic.appVersion = version
        CLIStatic.description = description
    }
    
    // MARK: - Registering commands
    
    class func registerCommand(command: Command) {
        CLIStatic.commands += command;
    }
    
    class func registerCommands(commands: [Command]) {
        for command in commands {
            self.registerCommand(command)
        }
    }
    
    class func registerChainableCommand(#commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        CLIStatic.commands += chainable
        return chainable
    }
    
    class func registerCustomHelpCommand(helpCommand: HelpCommand?) {
        CLIStatic.helpCommand = helpCommand
    }
    
    class func registerCustomVersionCommand(versionCommand: VersionCommand?) {
        CLIStatic.versionComand = versionCommand
    }
    
    class func registerDefaultCommand(command: Command) {
        CLIStatic.defaultCommand = command
    }
    
    // MARK: - Go
    
    class func go() -> Bool {
        var args = NSProcessInfo.processInfo().arguments as [String]
        
        self.prepareForRouting();
        
        var allCommands = CLIStatic.commands
        if let hc = CLIStatic.helpCommand {
            allCommands += hc
        }
        if let vc = CLIStatic.versionComand {
            allCommands += vc
        }
        
        let router = Router(commands: allCommands, arguments: args, defaultCommand: CLIStatic.defaultCommand)
        let result = router.route()
        
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
    
    class private func prepareForRouting() {
        if let hc = CLIStatic.helpCommand {
            hc.allCommands = CLIStatic.commands
        }
    }
    
}
