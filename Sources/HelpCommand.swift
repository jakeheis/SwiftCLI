//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class HelpCommand: CommandType {
    
    var allCommands: [CommandType] = []
    
    public var commandName: String  {
        return "help"
    }
    
    public var commandSignature: String {
        return ""
    }
    
    public var commandShortDescription: String  {
        return "Prints this help information"
    }
    
    public var commandShortcut: String?  {
        return "-h"
    }
    
    public var failOnUnrecognizedOptions: Bool  {
        return false
    }
    
    public func execute(arguments: CommandArguments) throws {
        print("\(CLI.appDescription)\n")
        print("Available commands: ")

        for command in allCommands {
            printCommand(command)
        }
        
        printCommand(self)
    }
    
    func printCommand(command: CommandType) {
        let description = command.commandShortDescription.padFront(totalLength: 20 - command.commandName.characters.count)
        print("- \(command.commandName)\(description)")
    }
    
}