//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Router {
    
    private let commands: [CommandType]
    private let arguments: RawArguments
    private let defaultCommand: CommandType
    
    enum RouterError: ErrorType {
        case CommandNotFound
        case ArgumentError
    }
    
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
            throw RouterError.ArgumentError
        }
        
        if commandSearchName.hasPrefix("-") {
            command = commands.filter({ $0.commandShortcut == commandSearchName }).first
            
            if command == nil {
                command = defaultCommand
            } else {
                arguments.classifyArgument(argument: commandSearchName, type: .CommandName)
            }
        } else {
            command = commands.filter { $0.commandName == commandSearchName }.first
            arguments.classifyArgument(argument: commandSearchName, type: .CommandName)
        }
        
        guard let foundCommand = command else {
            throw RouterError.CommandNotFound
        }
        
        return foundCommand
    }
    
}