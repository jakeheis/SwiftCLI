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
    
    public static var name = ""
    public static var version = "1.0"
    public static var description = ""
    
    private static var commands: [Command] = []
    
    public static var helpCommand: HelpCommand? = HelpCommand()
    public static var versionComand: Command? = VersionCommand()
    
    public static var router: Router = DefaultRouter()
    public static var usageStatementGenerator: UsageStatementGenerator = DefaultUsageStatementGenerator()
    public static var misusedOptionsMessageGenerator: MisusedOptionsMessageGenerator = DefaultMisusedOptionsMessageGenerator()
    
    public static var rawArgumentParser: RawArgumentParser = DefaultRawArgumentParser()
    public static var commandArgumentParser: CommandArgumentParser = DefaultCommandArgumentParser()
    public static var optionParser: OptionParser = DefaultOptionParser()
    
    // MARK: - Setup
    
    /**
        Sets the CLI up with basic information
    
        - Parameter name: name of the app, printed in the help message and command usage statements
        - Parameter version: version of the app, printed by the VersionCommand
        - Parameter description: description of the app, printed in the help message
    */
    public class func setup(name: String, version: String? = nil, description: String? = nil) {
        self.name = name
        
        if let version = version {
            self.version = version
        }
        
        if let description = description {
            self.description = description
        }
        
        Input.checkForPipedData()
    }
    
    /**
        Registers a command with the CLI for routing and execution. All commands must be registered 
        with this method or its siblings before calling `CLI.go()`
    
        - Parameter command: the command to be registered
    */
    public class func register(command: Command) {
        commands.append(command)
    }
    
    /**
        Registers a group of commands with the CLI for routing and execution. All commands must be registered
        with this method or its siblings before calling `CLI.go()`
    
        - Parameter commands: the commands to be registered
    */
    public class func register(commands: [Command]) {
        commands.forEach { self.register(command: $0) }
    }
    
    /**
        Registers a chainable command with the CLI for routing and execution.
    
        - Parameter commandName: the name of the new chainable command
        - Returns: a new chainable command for immediate chaining
    */
    public class func registerChainableCommand(name: String) -> ChainableCommand {
        let chainable = ChainableCommand(name: name)
        register(command: chainable)
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
       return go(with: RawArguments())
    }
    
    /**
        Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
        Uses the arguments passed in as an argument.
    
        - Parameter argumentString: the arguments to use when running the CLI
        - SeeAlso: `go()` when running from the command line
        - Returns: a CLIResult (Int) representing the success of the CLI in routing to and executing the correct
                    command. Usually should be passed to `exit(result)`
    */
    public class func debugGo(with argumentString: String) -> CLIResult {
        print("[Debug Mode]")
        return go(with: RawArguments(argumentString: argumentString))
    }
    
    // MARK: - Privates
    
    private class func go(with arguments: RawArguments) -> CLIResult {
        do {
            let command = try routeCommand(arguments: arguments)
            
            if let optionCommand = command as? OptionCommand {
                let result = try parseOptions(command: optionCommand, arguments: arguments)
                if case .exitEarly = result {
                    return CLIResult.Success
                }
            }
            
            let commandArguments = try parseArguments(command: command, arguments: arguments)
            try command.execute(arguments: commandArguments)
            
            return CLIResult.Success
        } catch CLIError.error(let error) {
            printError(error)
        } catch CLIError.emptyError {
            // Do nothing
        } catch let error as NSError {
            printError("An error occurred: \(error.localizedDescription)")
        }
        
        return CLIResult.Error
    }
    
    private class func routeCommand(arguments: RawArguments) throws -> Command {
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
    
    private class func parseOptions(command: OptionCommand, arguments: RawArguments) throws -> OptionParserResult {
        let optionRegistry = OptionRegistry()
        
        command.internalSetupOptions(options: optionRegistry)
        
        let result = optionParser.recognizeOptions(in: arguments, from: optionRegistry)
        
        if case .incorrectOptionUsage(let incorrectOptionUsage) = result {
            if let message = misusedOptionsMessageGenerator.generateMisusedOptionsStatement(for: command, incorrectOptionUsage: incorrectOptionUsage) {
                printError(message)
            }
            if command.failOnUnrecognizedOptions {
                throw CLIError.emptyError
            }
        }
        
        return result
    }
    
    private class func parseArguments(command: Command, arguments: RawArguments) throws -> CommandArguments {
        let commandSignature = CommandSignature(command.signature)
        return try CommandArguments(rawArguments: arguments, signature: commandSignature)
    }
    
}

// MARK: -

public enum CLIError: ErrorProtocol {
    case error(String)
    case emptyError
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
