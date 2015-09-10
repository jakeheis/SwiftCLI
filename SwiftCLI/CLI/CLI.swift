//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class CLI: NSObject {
    
    // MARK: - Information
    
    static var appName = ""
    static var appVersion = "1.0"
    static var appDescription = ""
    
    private static var commands: [CommandType] = []
    
    static var helpCommand: HelpCommand? = HelpCommand()
    static var versionComand: VersionCommand? = VersionCommand()
    static var defaultCommand: CommandType = helpCommand!
    
    static var routerConfig: Router.Config?
    
    // MARK: - Setup
    
    /**
        Sets the CLI up with basic information
    
        - Parameter name: name of the app, printed in the help message and command usage statements
        - Parameter version: version of the app, printed by the VersionCommand
        - Parameter description: description of the app, printed in the help message
    */
    public class func setup(name name: String, version: String = "1.0", description: String = "") {
        appName = name
        appVersion = version
        appDescription = description
    }
    
    /**
        Registers a command with the CLI for routing and execution. All commands must be registered 
        with this method or its siblings before calling `CLI.go()`
    
        - Parameter command: the command to be registered
    */
    public class func registerCommand(command: CommandType) {
        commands.append(command)
    }
    
    /**
        Registers a group of commands with the CLI for routing and execution. All commands must be registered
        with this method or its siblings before calling `CLI.go()`
    
        - Parameter commands: the commands to be registered
    */
    public class func registerCommands(commands: [CommandType]) {
        commands.each { self.registerCommand($0) }
    }
    
    /**
        Registers a chainable command with the CLI for routing and execution.
    
        - Parameter commandName: the name of the new chainable command
        - Returns: a new chainable command for immediate chaining
    */
    public class func registerChainableCommand(commandName commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        registerCommand(chainable)
        return chainable
    }
    
    // MARK: - Go
    
    /**
        Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments. 
        Uses the arguments passed in the command line.
    
        - SeeAlso: `debugGoWithArgumentString()` when debugging
        - Returns: a CLIResult (Int) representing the success of the CLI in routing to and executing the correct
                    command. Usually should be passed to `exit(result)`
    */
    public class func go() -> CLIResult {
       return goWithArguments(RawArguments())
    }
    
    /**
        Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
        Uses the arguments passed in as an argument.
    
        - Parameter argumentString: the arguments to use when running the CLI
        - SeeAlso: `go()` when running from the command line
        - Returns: a CLIResult (Int) representing the success of the CLI in routing to and executing the correct
                    command. Usually should be passed to `exit(result)`
    */
    public class func debugGoWithArgumentString(argumentString: String) -> CLIResult {
        print("[Debug Mode]")
        return goWithArguments(RawArguments(argumentString: argumentString))
    }
    
    private class func goWithArguments(arguments: RawArguments) -> CLIResult {
        do {
            let command = try routeCommand(arguments: arguments)
            let result = try setupOptionsAndArguments(command, arguments: arguments)
            if let arguments = result.arguments where result.execute {
                try command.execute(arguments)
            }
            
            return CLIResult.Success
        } catch CLIError.Error(let error) {
            printError(error)
        } catch CLIError.EmptyError {
            // Do nothing
        } catch _ {
            printError("An error occurred")
        }
        
        return CLIResult.Error
    }
    
    // MARK: - Privates
    
    class private func routeCommand(arguments arguments: RawArguments) throws -> CommandType {
        var allCommands = commands
        if let hc = helpCommand {
            hc.allCommands = commands
            allCommands.append(hc)
        }
        if let vc = versionComand {
            allCommands.append(vc)
        }
        
        let router = Router(commands: allCommands, arguments: arguments, defaultCommand: defaultCommand, config: routerConfig)        
        return try router.route()
    }
        
    class private func setupOptionsAndArguments(command: CommandType, arguments: RawArguments) throws -> (execute: Bool, arguments: CommandArguments?) {
        if let optionCommand = command as? OptionCommandType {
            let options = Options()
          
            optionCommand.internalSetupOptions(options)
            options.recognizeOptionsInArguments(arguments)
            
            if options.exitEarly { // True if -h flag given (show help but exit early before executing command)
                return (false, nil)
            }
            
            if options.misusedOptionsPresent() {
                if let message = CommandMessageGenerator.generateMisusedOptionsStatement(command: optionCommand, options: options) {
                    printError(message)
                }
                if optionCommand.failOnUnrecognizedOptions {
                    throw CLIError.EmptyError
                }
            }
        }
        
        let commandSignature = CommandSignature(command.commandSignature)
        
        return (true, try CommandArguments.fromRawArguments(arguments, signature: commandSignature))
    }
    
}

// MARK: -

public enum CLIError: ErrorType {
    case Error(String)
    case EmptyError
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