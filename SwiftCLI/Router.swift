//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation
//import LlamaKit

class Router {
    
    private let commands: [Command]
    private let arguments: RawArguments
    private let defaultCommand: Command
    
    struct Route {
        let command: Command
        let arguments: RawArguments
        
        init(command: Command, arguments: RawArguments) {
            self.command = command
            self.arguments = arguments
        }
    }
    
    init(commands: [Command], arguments: RawArguments, defaultCommand: Command) {
        self.commands = commands
        self.arguments = arguments
        self.defaultCommand = defaultCommand
    }
    
    func route() -> Result<Route, String> {
        if arguments.hasNoArguments {
            let result = Route(command: defaultCommand, arguments: arguments)
            return success(result)
        }
        
        return findCommand().map { Route(command: $0, arguments: self.arguments) }
    }
    
    // MARK: - Privates
    
    private func findCommand() -> Result<Command, String> {
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
            return success(command)
        }
        
        return failure("Command not found")
    }
    
}