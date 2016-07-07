//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol RouterType {
    func route(_ commands: [CommandType], arguments: RawArguments) throws -> CommandType
}

public class DefaultRouter: RouterType {
    
    private let defaultCommand: CommandType?
    
    public init(defaultCommand: CommandType? = nil) {
        self.defaultCommand = defaultCommand
    }
    
    public func route(_ commands: [CommandType], arguments: RawArguments) throws -> CommandType {
        guard arguments.unclassifiedArguments().count > 0 else {
            return try findDefaultCommand(commands)
        }
        
        return try findCommand(commands, arguments: arguments)
    }
    
    // MARK: - Privates
    
    private func findCommand(_ commands: [CommandType], arguments: RawArguments) throws -> CommandType {
        guard let commandSearchName = arguments.firstArgumentOfType(.unclassified) else {
            throw CLIError.error("Router failed")
        }
        
        if let command = commands.filter({ $0.commandName == commandSearchName }).first {
            arguments.classifyArgument(commandSearchName, type: .commandName)
            return command
        }
        
        if commandSearchName.hasPrefix("-") {
            if let shortcutCommand = commands.filter({ $0.commandShortcut == commandSearchName }).first {
                arguments.classifyArgument(commandSearchName, type: .commandName)
                return shortcutCommand
            } else {
                return try findDefaultCommand(commands)
            }
        }
        
        return try findDefaultCommand(commands)
    }
    
    func findDefaultCommand(_ commands: [CommandType]) throws -> CommandType {
        if let d = defaultCommand {
            return d
        }
        if let d = commands.flatMap({ $0 as? HelpCommand }).first {
            return d
        }
        throw CLIError.error("Command not found")
    }
    
}
