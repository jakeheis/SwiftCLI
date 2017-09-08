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
    
    public static var commands: [Command] = []
    
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
    @available(*, deprecated, message: "add commands directly to the CLI.commands array")
    public static func register(command: Command) {
        commands.append(command)
    }
    
    /// Registers a group of commands with the CLI for routing and execution. All commands must be registered
    /// with this method or its siblings before calling `CLI.go()`
    ///
    /// - Parameter commands: the commands to be registered
    @available(*, deprecated, message: "add commands directly to the CLI.commands array")
    public static func register(commands: [Command]) {
        commands.forEach { self.register(command: $0) }
    }
    
    /// Registers a chainable command with the CLI for routing and execution.
    ///
    /// - Parameter name: the name of the new chainable command
    /// - Returns: a new chainable command for immediate chaining
    @available(*, deprecated, message: "add a custom type implementing Command to the CLI.commands array")
    public static func registerChainableCommand(name: String) -> ChainableCommand {
        let chainable = ChainableCommand(name: name)
        register(command: chainable)
        return chainable
    }
    
    // MARK: - Go
    
    /// Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
    /// Uses the arguments passed in the command line.
    ///
    /// - SeeAlso: `debugGoWithArgumentString()` when debugging
    /// - Returns: a CLIResult (Int32) representing the success of the CLI in routing to and executing the correct
    /// command. Usually should be passed to `exit(result)`
    public static func go() -> Int32 {
        return go(with: ArgumentList())
    }
    
    /// Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
    /// Uses the argument string passed to this function.
    ///
    /// - SeeAlso: `go()` when running from the command line
    /// - Parameter argumentString: the arguments to use when running the CLI
    /// - Returns: a CLIResult (Int) representing the success of the CLI in routing to and executing the correct
    /// command. Usually should be passed to `exit(result)`
    public static func debugGo(with argumentString: String) -> Int32 {
        print("[Debug Mode]")
        return go(with: ArgumentList(argumentString: argumentString))
    }
    
    // MARK: - Privates
    
    private static func go(with arguments: ArgumentList) -> Int32 {
        argumentListManipulators.forEach { $0.manipulate(arguments: arguments) }
        
        var exitStatus: Int32 = 0
        
        do {
            // Step 1: route
            let command = try routeCommand(arguments: arguments)
            
            // Step 2: recognize options
            try recognizeOptions(of: command, in: arguments)
            if DefaultGlobalOptions.help.value == true {
                print(usageStatementGenerator.generateUsageStatement(for: command))
                return exitStatus
            }
            
            // Step 3: fill parameters
            try fillParameters(of: command, with: arguments)
            
            // Step 4: execute
            try command.execute()
        } catch let error as ProcessError {
            if let message = error.message {
                printError(message)
            }
            exitStatus = Int32(error.exitStatus)
        } catch let error {
            printError("An error occurred: \(error.localizedDescription)")
            exitStatus = 1
        }
        
        if exitStatus > 0 && helpCommand.executeOnCommandFailure {
            do {
                try helpCommand.execute()
            } catch let error {
                printError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        return exitStatus
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
            
            throw CLI.Error()
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
            throw CLI.Error(message: message)
        }
    }
    
    private static func fillParameters(of command: Command, with arguments: ArgumentList) throws {
        if command is HelpCommand {
            return
        }
        
        do {
            try parameterFiller.fillParameters(of: command, with: arguments)
        } catch let error as CLI.Error {
            if let message = error.message {
                printError(message)
            }
            printError(command.usage)
            throw CLI.Error(exitStatus: error.exitStatus)
        }
    }
    
}
