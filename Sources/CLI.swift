//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class CLI {
    
    // MARK: - Information
    
    public static var appName = ""
    public static var appVersion = "1.0"
    public static var appDescription = ""
    
    private static var commands: [CommandType] = []
    
    public static var helpCommand: HelpCommand? = HelpCommand()
    public static var versionComand: CommandType? = VersionCommand()
    
    public static var router: RouterType = DefaultRouter()
    
    // MARK: - Setup
    
    /**
        Sets the CLI up with basic information
    
        - Parameter name: name of the app, printed in the help message and command usage statements
        - Parameter version: version of the app, printed by the VersionCommand
        - Parameter description: description of the app, printed in the help message
    */
    public class func setup(name: String, version: String? = nil, description: String? = nil) {
        appName = name
        
        if let version = version {
            appVersion = version
        }
        
        if let description = description {
            appDescription = description
        }
        
        Input.checkForPipedData()
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
        commands.each { self.registerCommand(command: $0) }
    }
    
    /**
        Registers a chainable command with the CLI for routing and execution.
    
        - Parameter commandName: the name of the new chainable command
        - Returns: a new chainable command for immediate chaining
    */
    public class func registerChainableCommand(commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        registerCommand(command: chainable)
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
       return goWithArguments(arguments: RawArguments())
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
        return goWithArguments(arguments: RawArguments(argumentString: argumentString))
    }
    
    private class func goWithArguments(arguments: RawArguments) -> CLIResult {
        do {
            let command = try routeCommand(arguments: arguments)
            let result = try setupOptionsAndArguments(command: command, arguments: arguments)
            if let arguments = result.arguments where result.execute {
                try command.execute(arguments: arguments)
            }
            
            return CLIResult.Success
        } catch CLIError.Error(let error) {
            printError(error: error)
        } catch CLIError.EmptyError {
            // Do nothing
        } catch let error as NSError {
            printError(error: "An error occurred: \(error.localizedDescription)")
        }
        
        return CLIResult.Error
    }
    
    // MARK: - Privates
    
    class private func routeCommand(arguments: RawArguments) throws -> CommandType {
        var allCommands = commands
        if let hc = helpCommand {
            hc.allCommands = commands
            allCommands.append(hc)
        }
        if let vc = versionComand {
            allCommands.append(vc)
        }
        
        return try router.route(commands: allCommands, arguments: arguments)
    }
        
    class private func setupOptionsAndArguments(command: CommandType, arguments: RawArguments) throws -> (execute: Bool, arguments: CommandArguments?) {
        if let optionCommand = command as? OptionCommandType {
            let options = Options()
          
            optionCommand.internalSetupOptions(options: options)
            options.recognizeOptionsInArguments(rawArguments: arguments)
            
            if options.exitEarly { // True if -h flag given (show help but exit early before executing command)
                return (false, nil)
            }
            
            if options.misusedOptionsPresent() {
                if let message = CommandMessageGenerator.generateMisusedOptionsStatement(command: optionCommand, options: options) {
                    printError(error: message)
                }
                if optionCommand.failOnUnrecognizedOptions {
                    throw CLIError.EmptyError
                }
            }
        }
        
        let commandSignature = CommandSignature(command.commandSignature)
        
        return (true, try CommandArguments.fromRawArguments(rawArguments: arguments, signature: commandSignature))
    }
    
}

// MARK: -

public enum CLIError: ErrorProtocol {
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