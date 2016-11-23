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
    private static var aliases: [String: String] = [:]
    
    public static var helpCommand: HelpCommand = DefaultHelpCommand()
    public static var versionCommand: Command = VersionCommand()
    
    // MARK: - Advanced customization
    
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
    public static func setup(name: String, version: String? = nil, description: String? = nil) {
        self.name = name
        
        if let version = version {
            self.version = version
        }
        
        if let description = description {
            self.description = description
        }
        
        alias(from: "-h", to: "help")
        alias(from: "-v", to: "version")
    }
    
    /**
        Registers a command with the CLI for routing and execution. All commands must be registered 
        with this method or its siblings before calling `CLI.go()`
    
        - Parameter command: the command to be registered
    */
    public static func register(command: Command) {
        commands.append(command)
    }
    
    @available(*, unavailable, renamed: "register(command:)")
    public static func registerCommand(_ command: Command) {}
    
    /**
        Registers a group of commands with the CLI for routing and execution. All commands must be registered
        with this method or its siblings before calling `CLI.go()`
    
        - Parameter commands: the commands to be registered
    */
    public static func register(commands: [Command]) {
        commands.forEach { self.register(command: $0) }
    }
    
    @available(*, unavailable, renamed: "register(commands:)")
    public static func registerCommands(_ commands: [Command]) {}
    
    /**
        Registers a chainable command with the CLI for routing and execution.
    
        - Parameter commandName: the name of the new chainable command
        - Returns: a new chainable command for immediate chaining
    */
    public static func registerChainableCommand(name: String) -> ChainableCommand {
        let chainable = ChainableCommand(name: name)
        register(command: chainable)
        return chainable
    }
    
    @available(*, unavailable, renamed: "registerChainableCommand(name:)")
    public static func registerChainableCommand(commandName: String) -> ChainableCommand {
        return registerChainableCommand(name: commandName)
    }
    
    /**
        Aliases from one command name to another (e.g. from "-h" to "help" or from "co" to "checkout")
        - Parameter from: Command name from which the alias should be made (e.g. "-h")
        - Parameter to: Command name to which the alias should be made (e.g. "help")
    */
    public static func alias(from: String, to: String) {
        aliases[from] = to
    }
    
    /**
        Removes an alias from one command name to another
        - Parameter from: Alias source which should be removed
     */
    public static func removeAlias(from: String) {
        aliases.removeValue(forKey: from)
    }
    
    // MARK: - Go
    
    /**
        Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments. 
        Uses the arguments passed in the command line.
    
        - SeeAlso: `debugGoWithArgumentString()` when debugging
        - Returns: a CLIResult (Int) representing the success of the CLI in routing to and executing the correct
                    command. Usually should be passed to `exit(result)`
    */
    public static func go() -> CLIResult {
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
    public static func debugGo(with argumentString: String) -> CLIResult {
        print("[Debug Mode]")
        return go(with: RawArguments(argumentString: argumentString))
    }
    
    @available(*, unavailable, renamed: "debugGo(with:)")
    public static func debugGoWithArgumentString(_ argumentString: String) -> CLIResult {
        return debugGo(with: argumentString)
    }
    
    // MARK: - Privates
    
    private static func go(with arguments: RawArguments) -> CLIResult {
        do {
            let command = try routeCommand(arguments: arguments)
            
            if let optionCommand = command as? OptionCommand {
                let result = try parseOptions(command: optionCommand, arguments: arguments)
                if case .exitEarly = result {
                    return CLIResult.success
                }
            }
            
            let commandArguments: CommandArguments
            do {
                commandArguments = try parseArguments(command: command, arguments: arguments)
            } catch let CommandArgumentParserError.incorrectUsage(message) {
                printError(message)
                printError(command.usage)
                throw CLIError.emptyError
            } catch {
                throw error
            }
            
            try command.execute(arguments: commandArguments)
            
            return CLIResult.success
        } catch CLIError.error(let error) {
            printError(error)
        } catch CLIError.emptyError {
            // Do nothing
        } catch let error as NSError {
            printError("An error occurred: \(error.localizedDescription)")
        }
        
        if helpCommand.executeOnCommandFailure {
            do {
                try helpCommand.execute(arguments: CommandArguments())
            } catch let error as NSError {
                printError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        return CLIResult.error
    }
    
    private static func routeCommand(arguments: RawArguments) throws -> Command {
        var availableCommands = commands
        availableCommands.append(helpCommand)
        availableCommands.append(versionCommand)
        helpCommand.availableCommands = availableCommands
        
        guard let command = router.route(commands: availableCommands, aliases: aliases, arguments: arguments) else {
            if let attemptedCommandName = arguments.unclassifiedArguments.first?.value {
                printError("Command \"\(attemptedCommandName)\" not found\n")
                
                // Only print available commands if passed an unavailable command
                helpCommand.printCLIDescription = false
            }
            
            try helpCommand.execute(arguments: CommandArguments())
            
            throw CLIError.emptyError
        }
        
        return command
    }
    
    private static func parseOptions(command: OptionCommand, arguments: RawArguments) throws -> OptionParserResult {
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
    
    private static func parseArguments(command: Command, arguments: RawArguments) throws -> CommandArguments {
        let commandSignature = CommandSignature(command.signature)
        return try CommandArguments(rawArguments: arguments, signature: commandSignature)
    }
    
}

// MARK: -

public enum CLIError: Error {
    case error(String)
    case emptyError
}

public typealias CLIResult = Int32

extension CLIResult {
    
    public static var success: CLIResult {
        return 0
    }
    
    public static var error: CLIResult {
        return 1
    }
    
}

// MARK: - Compatibility

#if os(Linux)
typealias Regex = RegularExpression

#else
typealias Regex = NSRegularExpression

#endif
