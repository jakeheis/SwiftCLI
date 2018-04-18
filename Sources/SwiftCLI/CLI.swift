//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public class CLI {
    
    /// The name of the CLI; used in help messages
    public let name: String
    
    /// The version of the CLI; if non-nil, a VersionCommand is automatically created
    public let version: String?
    
    /// The description of the CLI; used in help messages
    public var description: String?
    
    /// The array of commands (or command groups)
    public var commands: [Routable]
    
    /// A built-in help command; set to nil if this functionality is not wanted
    public lazy var helpCommand: HelpCommand? = HelpCommand(cli: self)
    
    /// A built-in version command; set to nil if this functionality is not wanted
    public lazy var versionCommand: VersionCommand? = {
        if let version = version {
            return VersionCommand(version: version)
        }
        return nil
    }()
    
    /// Options which every command should inherit
    public var globalOptions: [Option] = []
    
    /// A built-in help flag which each command automatically inherits; set to nil if this functionality is not wanted
    public var helpFlag: Flag? = Flag("-h", "--help", description: "Show help information for this command")
    
    /// A map of command name aliases; by default, maps "-h" to help and "-v" to version
    public var aliases: [String : String] = [
        "-h": "help",
        "--help": "help",
        "-v": "version",
        "--version": "version"
    ]
    
    public var helpMessageGenerator: HelpMessageGenerator = DefaultHelpMessageGenerator()
    public var argumentListManipulators: [ArgumentListManipulator] = [OptionSplitter()]
    public var parser = Parser()
    
    /// Creates a new CLI
    ///
    /// - Parameter name: the name of the CLI executable
    /// - Parameter version: the current version of the CLI
    /// - Parameter description: a brief description of the CLI
    public init(name: String, version: String? = nil, description: String? = nil, commands: [Routable] = []) {
        self.name = name
        self.version = version
        self.description = description
        self.commands = commands
    }
    
    /// Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
    /// Uses the arguments passed in the command line. Exits the program upon completion.
    ///
    /// - SeeAlso: `debugGoWithArgumentString()` when debugging
    /// - Returns: Never
    public func goAndExit() -> Never {
        let result = go()
        exit(result)
    }
    
    /// Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
    /// Uses the arguments passed in the command line.
    ///
    /// - SeeAlso: `debugGoWithArgumentString()` when debugging
    /// - Returns: an Int32 representing the success of the CLI in routing to and executing the correct
    /// command. Usually should be passed to `exit(result)`
    public func go() -> Int32 {
        return go(with: ArgumentList())
    }
    
    /// Kicks off the entire CLI process, routing to and executing the command specified by the passed arguments.
    /// Uses the argument string passed to this function.
    ///
    /// - SeeAlso: `go()` when running from the command line
    /// - Parameter argumentString: the arguments to use when running the CLI
    /// - Returns: an Int32 representing the success of the CLI in routing to and executing the correct command. Usually should be passed to `exit(result)`
    public func debugGo(with argumentString: String) -> Int32 {
        stdout <<< "[Debug Mode]"
        return go(with: ArgumentList(argumentString: argumentString))
    }
    
    // MARK: - Privates
    
    private func go(with arguments: ArgumentList) -> Int32 {
        arguments.pop() // Pop off cli name (always first arg)
        
        argumentListManipulators.forEach { $0.manipulate(arguments: arguments) }
        
        var exitStatus: Int32 = 0
        
        do {
            let path = try parse(arguments: arguments)
            if helpFlag?.value == true {
                helpMessageGenerator.writeUsageStatement(for: path, to: stdout)
            } else {
                try path.command.execute()
            }
        } catch let error as ProcessError {
            if let message = error.message {
                stderr <<< message
            }
            exitStatus = Int32(error.exitStatus)
        } catch let error {
            stderr <<< "An error occurred: \(error)"
            exitStatus = 1
        }
        
        return exitStatus
    }
    
    private func parse(arguments: ArgumentList) throws -> CommandPath {
        do {
            return try parser.parse(commandGroup: self, arguments: arguments)
        } catch let error as RouteError {
            if let notFound = error.notFound {
                stderr <<< ""
                stderr <<< "Command \"\(notFound)\" not found"
            }
            
            helpMessageGenerator.writeCommandList(for: error.partialPath, to: stdout)
            throw CLI.Error()
        } catch let error as OptionError {
            if let command = error.command, command.command is HelpCommand {
                return command
            }
            
            helpMessageGenerator.writeMisusedOptionsStatement(for: error, to: stderr)
            throw CLI.Error()
        } catch let error as ParameterError {
            if error.command.command is HelpCommand || helpFlag?.value == true {
                return error.command
            }
            
            stderr <<< error.message
            stderr <<< "Usage: \(error.command.usage)"
            
            throw CLI.Error()
        }
    }
    
}

extension CLI: CommandGroup {
    
    public var shortDescription: String {
        return description ?? ""
    }
    
    public var children: [Routable] {
        var extra: [Routable] = []
        if let helpCommand = helpCommand {
            extra.append(helpCommand)
        }
        if let versionCommand = versionCommand {
            extra.append(versionCommand)
        }
        return commands + extra
    }
    
    public var options: [Option] {
        if let helpFlag = helpFlag {
            return globalOptions + [helpFlag]
        }
        return globalOptions
    }
    
}
