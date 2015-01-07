//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Failure
}

class CLI: NSObject {
    
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
    
    class func setup(#name: String, version: String = "1.0", description: String = "") {
        CLIStatic.appName = name
        CLIStatic.appVersion = version
        CLIStatic.appDescription = description
    }
    
    class func appName() -> String {
        return CLIStatic.appName
    }
    
    class func appDescription() -> String {
        return CLIStatic.appDescription
    }
    
    // MARK: - Registering commands
    
    class func registerCommand(command: Command) {
        CLIStatic.commands.append(command)
    }
    
    class func registerCommands(commands: [Command]) {
        for command in commands {
            registerCommand(command)
        }
    }
    
    class func registerChainableCommand(#commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        registerCommand(chainable)
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
    
    class func go() -> CLIResult {
       return goWithArguments(Arguments())
    }
    
    class func debugGoWithArgumentString(argumentString: String) -> CLIResult {
        return goWithArguments(Arguments(argumentString: argumentString))
    }
    
    private class func goWithArguments(arguments: Arguments) -> CLIResult {
        let routeResult = routeCommand(arguments: arguments)
        
        switch routeResult {
        case let .Success(route):
            return goWithRoute(route)
        case .Failure:
            printlnError("Command not found")
            return CLIResult.Error
        }
    }
    
    private class func goWithRoute(route: Router.Route) -> CLIResult {
        let optionResult = parseCommandLineArguments(route)
        
        switch optionResult {
        case let .Success(commandArguments):
            return executeRoute(route, commandArguments: commandArguments)
        case .Failure:
            return CLIResult.Error
        }
    }
    
    private class func executeRoute(route: Router.Route, commandArguments: [String]) -> CLIResult {
        if route.command.showingHelp { // Don't actually execute command if showing help, e.g. git clone -h
            return CLIResult.Success
        }
        
        let namedArguments = reconcileSignatureAndArguments(route.command.commandSignature(), arguments: commandArguments)
        if namedArguments == nil {
            return CLIResult.Error
        }
        route.command.arguments = namedArguments!
        
        let commandResult = route.command.execute()
        
        switch commandResult {
        case .Success:
            return CLIResult.Success
        case let .Failure(errorMessage):
            printlnError(errorMessage)
            return CLIResult.Error
        }
    }
    
    // MARK: - Privates
    
    class private func routeCommand(#arguments: Arguments) -> Result<Router.Route> {
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
    
    class private func parseCommandLineArguments(route: Router.Route) -> Result<[String]> {
        route.command.fillExpectedOptions()
        
        let commandArguments = route.command.parseCommandLineArguments(route.arguments)
        
        if let commandArguments = commandArguments {
            return .Success(commandArguments)
        }
        
        return .Failure
    }
    
    class private func reconcileSignatureAndArguments(signature: String, arguments: [String]) -> NSDictionary? {
        let parser = SignatureParser(signature: signature, arguments: arguments)
        let parseResult = parser.parse()
        
        switch parseResult.result {
        case let .Success(parsedArguments):
            return parsedArguments
        case .Failure:
            printlnError(parseResult.errorMessage!)
            return nil
        }
    }
    
}

typealias CLIResult = Int32

extension CLIResult {
    
    static var Success: CLIResult {
        return 0
    }
    
    static var Error: CLIResult {
        return 1
    }
    
}