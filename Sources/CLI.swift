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

    public static var argumentNodeParser: ArgumentNodeParser = DefaultArgumentNodeParser()
    public static var optionParser: OptionParser = DefaultOptionParser()
    public static var commandArgumentParser: CommandArgumentParser = DefaultCommandArgumentParser()

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
    
    /// For testing
    internal static func clearCommands() {
        commands = []
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
       return go(with: ArgumentList())
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
        return go(with: ArgumentList(argumentString: argumentString))
    }

    @available(*, unavailable, renamed: "debugGo(with:)")
    public static func debugGoWithArgumentString(_ argumentString: String) -> CLIResult {
        return debugGo(with: argumentString)
    }

    // MARK: - Privates

    private static func go(with arguments: ArgumentList) -> CLIResult {
        do {
            // Step 1: route
            let command = try routeCommand(arguments: arguments)

            // Step 2: parse options
            try parseOptions(command: command, arguments: arguments)
            if command.helpFlag?.value == true {
                return CLIResult.success
            }

            // Step 3: parse arguments
            do {
                try commandArgumentParser.parse(arguments: arguments, for: command)
            } catch let CommandArgumentParserError.incorrectUsage(message) {
                printError(message)
                printError(command.usage)
                throw CLIError.emptyError
            } catch {
                throw error
            }

            // Step 4: execute
            try command.execute()

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
                try helpCommand.execute()
            } catch let error as NSError {
                printError("An error occurred: \(error.localizedDescription)")
            }
        }

        return CLIResult.error
    }

    private static func routeCommand(arguments: ArgumentList) throws -> Command {
        var availableCommands = commands
        availableCommands.append(helpCommand)
        availableCommands.append(versionCommand)
        helpCommand.availableCommands = availableCommands

        guard let command = router.route(commands: availableCommands, aliases: aliases, arguments: arguments) else {
            if let attemptedCommandName = arguments.head {
                printError("Command \"\(attemptedCommandName)\" not found\n")

                // Only print available commands if passed an unavailable command
                helpCommand.printCLIDescription = false
            }

            try helpCommand.execute()

            throw CLIError.emptyError
        }

        return command
    }

    private static func parseOptions(command: Command, arguments: ArgumentList) throws {
        if command is HelpCommand {
            return
        }
        
        let optionRegistry = OptionRegistry(command: command)

        do {
            try optionParser.recognizeOptions(in: arguments, from: optionRegistry)
        } catch let error as OptionParserError {
            let message = misusedOptionsMessageGenerator.generateMisusedOptionsStatement(for: command, error: error)
            throw CLIError.error(message)
        }
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
