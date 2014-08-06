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
    
    private let commands: [Command]
    private let arguments: [String]
    private var defaultCommand: Command
    
    init(commands: [Command], arguments: [String], defaultCommand: Command) {
        self.commands = commands
        self.arguments = arguments
        self.defaultCommand = defaultCommand
    }
    
    func route() -> RouterResult {
        if self.arguments.count == 1 { // e.g. "bundle"
            return .Success(self.defaultCommand, [], Options(), "")
        }
        
        let commandString = self.arguments[1]

        let (command, commandName, remainingArgumentsIndex) = self.findCommand(commandString)
        
        if command == nil {
            return .Failure
        }
        
        let segmentedArguments = self.segmentArgumentsWithStartingIndex(remainingArgumentsIndex)
        
        return .Success(command!, segmentedArguments.commandArguments, Options(arguments: segmentedArguments.optionArguments), commandName)
    }
    
    // MARK: - Privates
    
    private func findCommand(commandString: String) -> (command: Command?, commandName: String, remainingArgumentsIndex: Int) {
        var command: Command?
        var cmdName: String = commandString
        var argumentsStartingIndex = 2
        
        if commandString.hasPrefix("-") {
            command = self.findCommandWithShortcut(commandString)
            
            // If no command with shorcut found, pass the -arg as a flag to the default command
            if command == nil {
                command = self.defaultCommand
                argumentsStartingIndex = 1
                cmdName = ""
            }
        } else {
            command = self.findCommandWithName(commandString)
        }
        
        return (command, cmdName, argumentsStartingIndex)
    }
    
    private func findCommandWithShortcut(commandShortcut: String) -> Command? {
        for command in self.commands {
            if commandShortcut == command.commandShortcut() {
                return command
            }
        }
        
        return nil
    }
    
    private func findCommandWithName(commandName: String) -> Command? {
        for command in self.commands {
            if commandName == command.commandName() {
                return command
            }
        }
        
        return nil
    }
    
    private func segmentArgumentsWithStartingIndex(argumentsStartingIndex: Int) -> (commandArguments: [String], optionArguments: [String]){
        if self.arguments.count <= argumentsStartingIndex {
            return ([], [])
        }
        
        let remainingArguments = self.arguments[argumentsStartingIndex..<self.arguments.count]
        
        var splitIndex: Int = remainingArguments.count
        for index in 0..<remainingArguments.count {
            let arg = remainingArguments[index] as String
            if arg.hasPrefix("-") {
                splitIndex = index
                break
            }
        }
        
        let commandArguments = Array(remainingArguments[0..<splitIndex])
        let optionArguments = Array(remainingArguments[splitIndex..<remainingArguments.count])
        
        return (commandArguments, optionArguments)
    }
    
}