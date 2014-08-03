//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

enum RouterResult {
    case Success(Command, [String], Options, String)
    case Failure
}

class Router {
    
    var commands: [Command]
    
    // TODO: move these to CLI once class variables are supported
    // Special built-in commands
    var helpCommand: HelpCommand?
    var versionComand: VersionCommand?
    var defaultCommand: Command
    
    init() {
        self.commands = []
        self.helpCommand = HelpCommand.command()
        self.versionComand = VersionCommand.command()
        self.defaultCommand = self.helpCommand!
    }
    
    func route(#arguments: [String]) -> RouterResult {
        self.prepForRouting()
        
        if arguments.count == 1 { // e.g. "bundle"
            return .Success(self.defaultCommand, [], Options(args: []), "")
        }
        
        let commandString = arguments[1]

        var command: Command?
        var cmdName: String = commandString
        var argumentsStartingIndex = 2
        
        if commandString.hasPrefix("-") {
            command = self.findCommandWithShortcut(commandString)
            
            // If no command with shorcut found, pass the -arg as a flag to the default command
            if !command {
                command = self.defaultCommand
                argumentsStartingIndex = 1
                cmdName = ""
            }
        } else {
            command = self.findCommandWithName(commandString)
        }
        
        if !command {
            return .Failure
        }
        
        var commandParameters = [String]()
        var commandOptions = [String]()
        
        if arguments.count > argumentsStartingIndex {
            let commandArguments = arguments[argumentsStartingIndex..<arguments.count]
            
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
        
        return .Success(command!, commandParameters, Options(args: commandOptions), cmdName)
    }
    
    private func findCommandWithShortcut(commandShortcut: String) -> Command? {
        for command in self.allAvailableCommands() {
            if commandShortcut == command.commandShortcut() {
                return command
            }
        }
        
        return nil
    }
    
    private func findCommandWithName(commandName: String) -> Command? {
        for command in self.allAvailableCommands() {
            if commandName == command.commandName() {
                return command
            }
        }
        
        return nil
    }
    
    private func allAvailableCommands() -> [Command] {
        var availableCommands = self.commands
        
        if self.helpCommand {
            availableCommands += self.helpCommand!
        }
        if self.versionComand {
            availableCommands += self.versionComand!
        }
        
        return availableCommands;
    }
    
    private func prepForRouting() {
        if self.helpCommand {
            self.helpCommand!.allCommands = self.commands;
        }
    }
    
    
}