//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Router {
    
    var commands: [Command]
    
    // Special built-in commands
    var helpCommand: HelpCommand
    var versionComand: Command?
    
    init() {
        self.commands = []
        self.helpCommand = HelpCommand.command()
        self.versionComand = nil
    }
    
    func route(#arguments: [String]) -> (command: Command?, parameters: [String], options: Options) {
        self.prepSpecialCommands()
        
        if arguments.count == 1 {
            return (self.helpCommand, [], Options(args: []))
        }
        
        let commandString = arguments[1]
        
        var commandParameters = [String]()
        var commandOptions = [String]()
        
        if arguments.count > 2 {
            let commandArguments = arguments[2..<arguments.count]
            
            var splitIndex: Int = commandArguments.count
            for index in 0..<commandArguments.count {
                let arg = commandArguments[index] as String
                if arg.hasPrefix("-") {
                    splitIndex = index
                    break
                }
            }
            
            commandParameters = Array(commandArguments[0..<splitIndex])
            commandOptions = Array(commandArguments[splitIndex..<commandArguments.count])
        }
        
        self.prepSpecialCommands()
        
        let command = self.findCommand(commandString)
        
        return (command: command, parameters: commandParameters, options: Options(args: commandOptions))
    }
    
    private func findCommand(commandName: String) -> Command? {
        var availableCommands = self.commands
        availableCommands += self.helpCommand
        
        if let vc = self.versionComand {
            availableCommands += vc
        }
    
        for command in availableCommands {
            if commandName == command.commandName {
                return command
            }
        }
        
        if commandName == "-h" {
            return self.helpCommand
        } else if commandName == "-v" {
            return self.versionComand
        }
    
        return nil
    }
    
    private func prepSpecialCommands() {
        self.helpCommand.allCommands = self.commands
    }
    
    
}