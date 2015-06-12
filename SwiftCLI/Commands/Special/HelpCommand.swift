//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class HelpCommand: Command {
    
    var allCommands: [CommandType] = []
    
    override public var commandName: String  {
        return "help"
    }
    
    override public var commandShortDescription: String  {
        return "Prints this help information"
    }
    
    override public var commandShortcut: String?  {
        return "-h"
    }
    
    override public var showHelpOnHFlag: Bool  {
        return false
    }
    
    override public var failOnUnrecognizedOptions: Bool  {
        return false
    }
    
    override public func execute(#arguments: CommandArguments) -> ExecutionResult  {
        println("\(CLI.appDescription())\n")
        println("Available commands: ")

        for command in allCommands {
            printCommand(command)
        }
        
        printCommand(self)
        
        return success()
    }
    
    func printCommand(command: CommandType) {
        let description = command.commandShortDescription.padFront(totalLength: 20 - count(command.commandName))
        println("- \(command.commandName)\(description)")
    }
    
}