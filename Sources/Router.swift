//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol Router {
    func route(commands: [Command], arguments: RawArguments) throws -> Command
}

public class DefaultRouter: Router {
    
    private let defaultCommand: Command?
    
    public init(defaultCommand: Command? = nil) {
        self.defaultCommand = defaultCommand
    }
    
    public func route(commands: [Command], arguments: RawArguments) throws -> Command {
        guard arguments.unclassifiedArguments.count > 0 else {
            return try findDefaultCommand(commands: commands)
        }
        
        return try findCommand(commands: commands, arguments: arguments)
    }
    
    // MARK: - Privates
    
    private func findCommand(commands: [Command], arguments: RawArguments) throws -> Command {
        guard let commandNameArgument = arguments.unclassifiedArguments.first else {
            throw CLIError.error("Router failed")
        }
        
        if let command = commands.filter({ $0.name == commandNameArgument.value }).first {
            commandNameArgument.classification = .commandName
            return command
        }
        
        if commandNameArgument.value.hasPrefix("-") {
            if let shortcutCommand = commands.filter({ $0.shortcut == commandNameArgument.value }).first {
                commandNameArgument.classification = .commandName
                return shortcutCommand
            } else {
                return try findDefaultCommand(commands: commands)
            }
        }
        
        return try findDefaultCommand(commands: commands)
    }
    
    func findDefaultCommand(commands: [Command]) throws -> Command {
        if let d = defaultCommand {
            return d
        }
        if let d = commands.flatMap({ $0 as? HelpCommand }).first {
            return d
        }
        throw CLIError.error("Command not found")
    }
    
}
