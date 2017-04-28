//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class CLI {
    
    // MARK: - Information
    
    public static var name = ""
    public static var version = "1.0"
    public static var description = ""
    
    public static var helpCommand: HelpCommand = DefaultHelpCommand()
    public static var versionCommand: Command = VersionCommand()
    
    // MARK: - Advanced customization
    
    public static var usageStatementGenerator: UsageStatementGenerator = DefaultUsageStatementGenerator()
    public static var misusedOptionsMessageGenerator: MisusedOptionsMessageGenerator
        = DefaultMisusedOptionsMessageGenerator()
    
    public static var argumentListManipulators: [ArgumentListManipulator] = [CommandAliaser(), OptionSplitter()]
    public static var router: Router = DefaultRouter()
    public static var optionRecognizer: OptionRecognizer = DefaultOptionRecognizer()
    public static var parameterFiller: ParameterFiller = DefaultParameterFiller()
    
    // MARK: - Private
    
    private static var commands: [Command] = []
    
    // MARK: - Setup
    
    /// Sets the CLI up with basic information
    ///
    /// - Parameters:
    ///   - name: name of the app, printed in the help message and command usage statements
    ///   - version: version of the app, printed by the VersionCommand
    ///   - description: description of the app, printed in the help message
    public static func setup(name: String, version: String? = nil, description: String? = nil) {
        self.name = name
        
        if let version = version {
            self.version = version
        }
        
        if let description = description {
            self.description = description
        }
    }
    
    /// Registers a command with the CLI for routing and execution. All commands must be registered
    /// with this method or its siblings before calling `CLI.go()`
    ///
    /// - Parameter command: the command to be registered
    public static func register(command: Command) {
        commands.append(command)
    }
    
    /// Registers a group of commands with the CLI for routing and execution. All commands must be registered
    /// with this method or its siblings before calling `CLI.go()`
    ///
    /// - Parameter commands: the commands to be registered
    public static func register(commands: [Command]) {
        commands.forEach { self.register(command: $0) }
    }
    
    /// Registers a chainable command with the CLI for routing and execution.
    ///
    /// - Parameter name: the name of the new chainable command
    /// - Returns: a new chainable command for immediate chaining
    @available(*, deprecated, message: "register(command:) a custom type implementing Command instead")
    public static func registerChainableCommand(name: String) -> ChainableCommand {
        let chainable = ChainableCommand(name: name)
        register(command: chainable)
        return chainable
    }
    
    /// For testing; don't use
    internal static func reset() {
        commands = []
        argumentListManipulators = [CommandAliaser(), OptionSplitter()]
        GlobalOptions.options = DefaultGlobalOptions.options
        CommandAliaser.reset()
    }
    
    // MARK: - Go
    
    /// Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
    /// Uses the arguments passed in the command line.
    ///
    /// - SeeAlso: `debugGoWithArgumentString()` when debugging
    /// - Returns: a CLIResult (Int32) representing the success of the CLI in routing to and executing the correct
    /// command. Usually should be passed to `exit(result)`
    public static func go() -> CLIResult {
        return go(with: ArgumentList())
    }
    
    /// Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
    /// Uses the argument string passed to this function.
    ///
    /// - SeeAlso: `go()` when running from the command line
    /// - Parameter argumentString: the arguments to use when running the CLI
    /// - Returns: a CLIResult (Int) representing the success of the CLI in routing to and executing the correct
    /// command. Usually should be passed to `exit(result)`
    public static func debugGo(with argumentString: String) -> CLIResult {
        print("[Debug Mode]")
        return go(with: ArgumentList(argumentString: argumentString))
    }
    
    // MARK: - Privates
    
    private static func go(with arguments: ArgumentList) -> CLIResult {
        argumentListManipulators.forEach { $0.manipulate(arguments: arguments) }
        
        do {
            // Step 1: route
            let command = try routeCommand(arguments: arguments)
            
            // Step 2: recognize options
            try recognizeOptions(of: command, in: arguments)
            if DefaultGlobalOptions.help.value == true {
                print(usageStatementGenerator.generateUsageStatement(for: command))
                return CLIResult.success
            }
            
            // Step 3: fill parameters
            try fillParameters(of: command, with: arguments)
            
            // Step 4: execute
            try command.execute()
            
            return CLIResult.success
        } catch CLIError.error(let error) {
            printError(error)
        } catch CLIError.emptyError {
            // Do nothing
        } catch let error {
            printError("An error occurred: \(error.localizedDescription)")
        }
        
        if helpCommand.executeOnCommandFailure {
            do {
                try helpCommand.execute()
            } catch let error {
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
        
        guard let command = router.route(commands: availableCommands, arguments: arguments) else {
            if let attemptedCommandName = arguments.head {
                printError("Command \"\(attemptedCommandName.value)\" not found\n")
                
                // Only print available commands if passed an unavailable command
                helpCommand.printCLIDescription = false
            }
            
            try helpCommand.execute()
            
            throw CLIError.emptyError
        }
        
        return command
    }
    
    private static func recognizeOptions(of command: Command, in arguments: ArgumentList) throws {
        if command is HelpCommand {
            return
        }
        
        do {
            try optionRecognizer.recognizeOptions(of: command, in: arguments)
        } catch let error as OptionRecognizerError {
            let message = misusedOptionsMessageGenerator.generateMisusedOptionsStatement(for: command, error: error)
            throw CLIError.error(message)
        }
    }
    
    private static func fillParameters(of command: Command, with arguments: ArgumentList) throws {
        if command is HelpCommand {
            return
        }
        
        do {
            try parameterFiller.fillParameters(of: command, with: arguments)
        } catch let error as ParameterFillerError {
            printError(error.message)
            printError(command.usage)
            throw CLIError.emptyError
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
