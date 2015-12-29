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
        
        /// Allow shortcut flags to be routed to commands; e.g. route -h to the HelpCommand
        public var enableShortcutRouting: Bool = true
        
        init() {}
        
        init(enableShortcutRouting: Bool) {
            self.enableShortcutRouting = enableShortcutRouting
        }
    }
    
    private let commands: [CommandType]
    private let arguments: RawArguments
    private let defaultCommand: CommandType
    
    private var config: Config
    
    static let CommandNotFoundError = CLIError.Error("Command not found")
    static let ArgumentError = CLIError.Error("Router failed")
    
    init(commands: [CommandType], arguments: RawArguments, defaultCommand: CommandType, config: Config?) {
        self.commands = commands
        self.arguments = arguments
        self.defaultCommand = defaultCommand
        
        self.config = config ?? Config()
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
                where config.enableShortcutRouting {
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
            throw Router.CommandNotFoundError
        }
        
        return foundCommand
    }
    
}