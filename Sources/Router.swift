//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol RouterType {
    func route(commands: [CommandType], arguments: RawArguments) throws -> CommandType
}

public class DefaultRouter: RouterType {
    
    private let defaultCommand: CommandType?
    
    public init(defaultCommand: CommandType? = nil) {
        self.defaultCommand = defaultCommand
    }
    
    public func route(commands: [CommandType], arguments: RawArguments) throws -> CommandType {
        guard arguments.unclassifiedArguments().count > 0 else {
            return try findDefaultCommand(commands: commands)
        }
        
        return try findCommand(commands: commands, arguments: arguments)
    }
    
    // MARK: - Privates
    
    private func findCommand(commands: [CommandType], arguments: RawArguments) throws -> CommandType {
        guard let commandSearchName = arguments.firstArgumentOfType(type: .Unclassified) else {
            throw CLIError.Error("Router failed")
        }
        
        if let command = commands.filter({ $0.commandName == commandSearchName }).first {
            arguments.classifyArgument(argument: commandSearchName, type: .CommandName)
            return command
        }
        
        if commandSearchName.hasPrefix("-") {
            if let shortcutCommand = commands.filter({ $0.commandShortcut == commandSearchName }).first {
                arguments.classifyArgument(argument: commandSearchName, type: .CommandName)
                return shortcutCommand
            } else {
                return try findDefaultCommand(commands: commands)
            }
        }
        
        return try findDefaultCommand(commands: commands)
    }
    
    func findDefaultCommand(commands: [CommandType]) throws -> CommandType {
        if let d = defaultCommand {
            return d
        }
        if let d = commands.flatMap({ $0 as? HelpCommand }).first {
            return d
        }
        throw CLIError.Error("Command not found")
    }
    
}
