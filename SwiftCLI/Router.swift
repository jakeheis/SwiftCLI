//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Router {
    
    private let commands: [Command]
    private let arguments: Arguments
    private let defaultCommand: Command
    
    struct Route {
        let command: Command
        let arguments: Arguments
        
        init(command: Command, arguments: Arguments) {
            self.command = command
            self.arguments = arguments
        }
    }
    
    init(commands: [Command], arguments: Arguments, defaultCommand: Command) {
        self.commands = commands
        self.arguments = arguments
        self.defaultCommand = defaultCommand
    }
    
    func route() -> Result<Route> {
        if arguments.hasNoArguments {
            let result = Route(command: defaultCommand, arguments: arguments)
            return .Success(result)
        }
        
        let commandResult = findCommand()
        
        switch commandResult {
        case let .Success(command):
            let route = Route(command: command, arguments: arguments)
            return .Success(route)
        case .Failure:
            return .Failure
        }
    }
    
    // MARK: - Privates
    
    private func findCommand() -> Result<Command> {
        var command: Command?
        
        if arguments.firstArgumentIsFlag {
            command = commands.filter({ $0.commandShortcut() == self.arguments.firstArgument! }).first
            
            if command == nil {
                command = defaultCommand
            } else {
                arguments.setFirstArgumentIsCommandName()
            }
        } else {
            command = commands.filter({ $0.commandName() == self.arguments.firstArgument! }).first
            arguments.setFirstArgumentIsCommandName()
        }
        
        if let command = command {
            return .Success(command)
        }
        
        return .Failure
    }
    
}