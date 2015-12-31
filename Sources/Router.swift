//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class Router {
    
    /// Optional configuration for the Router
    public struct Config {
        
        /// Allow shortcut flags to be routed to commands (e.g. route -h to the HelpCommand); default true
        static public let enableShortcutRouting: Bool = true
        
        /// If true, execute the default command if no command is found; if false, instead show the help message; default false
        static public let fallbackToDefaultCommand: Bool = false
    }
    
    private let commands: [CommandType]
    private let arguments: RawArguments
    private let defaultCommand: CommandType
    
    static let CommandNotFoundError = CLIError.Error("Command not found")
    static let ArgumentError = CLIError.Error("Router failed")
    
    init(commands: [CommandType], arguments: RawArguments, defaultCommand: CommandType) {
        self.commands = commands
        self.arguments = arguments
        self.defaultCommand = defaultCommand
    }
    
    func route() throws -> CommandType {
        guard arguments.unclassifiedArguments().count > 0 else {
            return defaultCommand
        }
        
        return try findCommand()
    }
    
    // MARK: - Privates
    
    private func findCommand() throws -> CommandType {
        var command: CommandType?
        
        guard let commandSearchName = arguments.firstArgumentOfType(.Unclassified) else {
            throw Router.ArgumentError
        }
        
        if commandSearchName.hasPrefix("-") {
            if let shortcutCommand = commands.filter({ $0.commandShortcut == commandSearchName }).first
                where Config.enableShortcutRouting {
                command = shortcutCommand
                arguments.classifyArgument(argument: commandSearchName, type: .CommandName)
            } else {
                command = defaultCommand
            }
        } else {
            command = commands.filter { $0.commandName == commandSearchName }.first
            arguments.classifyArgument(argument: commandSearchName, type: .CommandName)
        }
        
        guard let foundCommand = command else {
            if Config.fallbackToDefaultCommand {
              return defaultCommand
            }
            throw Router.CommandNotFoundError
        }
        
        return foundCommand
    }
    
}