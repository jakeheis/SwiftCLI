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
    
    public static var commands: [Routable] = []
    
    public static var helpCommand: Command = HelpCommand()
    public static var versionCommand: Command = VersionCommand()
        
    // MARK: - Advanced customization
    
    public static var helpMessageGenerator: HelpMessageGenerator = DefaultHelpMessageGenerator()
    
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
        commands += [helpCommand, versionCommand]
        
        argumentListManipulators.forEach { $0.manipulate(arguments: arguments) }
        
        var exitStatus: Int32 = 0
        
        do {
            // Step 1: route
            let command = try routeCommand(arguments: arguments)
            
            // Step 2: recognize options
            try recognizeOptions(of: command, in: arguments)
            if DefaultGlobalOptions.help.value == true {
                print(helpMessageGenerator.generateUsageStatement(for: command))
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
        
        return exitStatus
    }
    
    private static func routeCommand(arguments: ArgumentList) throws -> Command {
        let routeResult = router.route(routables: commands, arguments: arguments)
        
        switch routeResult {
        case let .success(command):
            return command
        case let .failure(partialPath: partialPath, group: group, attempted: attempted):
            if let attempted = attempted {
                printError("Command \"\(attempted)\" not found\n")
            }
            let description: String?
            let routables: [Routable]
            if let group = group {
                description = attempted == nil ? group.shortDescription : nil
                routables = group.children
            } else {
                description = attempted == nil ? CLI.description : nil
                routables = commands
            }
            let list = helpMessageGenerator.generateCommandList(
                prefix: partialPath,
                description: description,
                routables: routables
            )
            print(list)
            throw CLI.Error()
        }
    }
    
    private static func recognizeOptions(of command: Command, in arguments: ArgumentList) throws {
        if command is HelpCommand {
            return
        }
        
        do {
            try optionRecognizer.recognizeOptions(of: command, in: arguments)
        } catch let error as OptionRecognizerError {
            let message = helpMessageGenerator.generateMisusedOptionsStatement(for: command, error: error)
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
