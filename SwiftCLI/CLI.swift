//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation
//import LlamaKit

public class CLI: NSObject {
    
    // MARK: - Information
    
    private struct CLIStatic {
        static var appName = ""
        static var appVersion = "1.0"
        static var appDescription = ""
        
        static var commands: [Command] = []
        static var helpCommand: HelpCommand? = HelpCommand()
        static var versionComand: VersionCommand? = VersionCommand()
        static var defaultCommand: Command = CLIStatic.helpCommand!
    }
    
    public class func setup(#name: String, version: String = "1.0", description: String = "") {
        CLIStatic.appName = name
        CLIStatic.appVersion = version
        CLIStatic.appDescription = description
    }
    
    public class func appName() -> String {
        return CLIStatic.appName
    }
    
    public class func appDescription() -> String {
        return CLIStatic.appDescription
    }
    
    // MARK: - Registering commands
    
    public class func registerCommand(command: Command) {
        CLIStatic.commands.append(command)
    }
    
    public class func registerCommands(commands: [Command]) {
        for command in commands {
            registerCommand(command)
        }
    }
    
    public class func registerChainableCommand(#commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        registerCommand(chainable)
        return chainable
    }
    
    public class func registerCustomHelpCommand(helpCommand: HelpCommand?) {
        CLIStatic.helpCommand = helpCommand
    }
    
    public class func registerCustomVersionCommand(versionCommand: VersionCommand?) {
        CLIStatic.versionComand = versionCommand
    }
    
    public class func registerDefaultCommand(command: Command) {
        CLIStatic.defaultCommand = command
    }
    
    // MARK: - Go
    
    public class func go() -> CLIResult {
       return goWithArguments(RawArguments())
    }
    
    public class func debugGoWithArgumentString(argumentString: String) -> CLIResult {
        return goWithArguments(RawArguments(argumentString: argumentString))
    }
    
    private class func goWithArguments(arguments: RawArguments) -> CLIResult {
        let result = routeCommand(arguments: arguments)
        .flatMap( {(route) -> Result<Router.Route, String> in
            if self.setupOptionsAndArguments(route) {
                return success(route)
            } else {
                return failure("")
            }
        })
        .flatMap( {(route) -> Result<(), String> in
            if route.command.showingHelp { // Don't actually execute command if showing help, e.g. git clone -h
                return success()
            }
            
            return route.command.execute()
        })
        
        if result.isSuccess {
            return CLIResult.Success
        } else {
            if let error = result.error where !error.isEmpty {
                printlnError(error)
            }
            return CLIResult.Error
        }
    }
    
    // MARK: - Privates
    
    class private func routeCommand(#arguments: RawArguments) -> Result<Router.Route, String> {
        var allCommands = CLIStatic.commands
        if let hc = CLIStatic.helpCommand {
            hc.allCommands = CLIStatic.commands
            allCommands.append(hc)
        }
        if let vc = CLIStatic.versionComand {
            allCommands.append(vc)
        }
        
        let router = Router(commands: allCommands, arguments: arguments, defaultCommand: CLIStatic.defaultCommand)
        
        return router.route()
    }
    
    class private func setupOptionsAndArguments(route: Router.Route) -> Bool {
        route.command.setupExpectedOptions()
        
        if route.command.recognizeOptions(route.arguments) {
            if route.command.showingHelp {
                return true
            }
            
            let commandSignature = CommandSignature(route.command.commandSignature())
            let commandArgumentsResult = CommandArguments.fromRawArguments(route.arguments, signature: commandSignature)
            
            if let commandArguments = commandArgumentsResult.value {
                route.command.arguments = commandArguments
                return true
            }
            
            if let errorMessage = commandArgumentsResult.error {
                printlnError(errorMessage)
            }
        }
        
        return false
    }
    
}

public typealias CLIResult = Int32

extension CLIResult {
    
    static var Success: CLIResult {
        return 0
    }
    
    static var Error: CLIResult {
        return 1
    }
    
}