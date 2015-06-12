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
    
    struct Route {
        let command: CommandType
        let arguments: RawArguments
        
        init(command: CommandType, arguments: RawArguments) {
            self.command = command
            self.arguments = arguments
        }
    }
    
    init(commands: [CommandType], arguments: RawArguments, defaultCommand: CommandType) {
        self.commands = commands
        self.arguments = arguments
        self.defaultCommand = defaultCommand
    }
    
    func route() -> Result<Route, String> {
        if arguments.unclassifiedArguments().count == 0 {
            let result = Route(command: defaultCommand, arguments: arguments)
            return success(result)
        }
        
        return findCommand().map { Route(command: $0, arguments: self.arguments) }
    }
    
    // MARK: - Privates
    
    private func findCommand() -> Result<CommandType, String> {
        var command: CommandType?
        
        if let commandSearchName = arguments.firstArgumentOfType(.Unclassified) {
            
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
            
            if let command = command {
                return success(command)
            }
            
        }
        
        return failure("Command not found")
    }
    
}