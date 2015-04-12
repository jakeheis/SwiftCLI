//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class HelpCommand: Command {
    
    var allCommands: [Command] = []
    
    override public func commandName() -> String  {
        return "help"
    }
    
    override public func commandShortDescription() -> String  {
        return "Prints this help information"
    }
    
    override public func commandShortcut() -> String?  {
        return "-h"
    }
    
    override public func showHelpOnHFlag() -> Bool  {
        return false
    }
    
    override public func failOnUnrecognizedOptions() -> Bool  {
        return false
    }
    
    override public func execute() -> ExecutionResult  {
        println("\(CLI.appDescription())\n")
        println("Available commands: ")

        for command in allCommands {
            printCommand(command)
        }
        
        printCommand(self)
        
        return success()
    }
    
    func printCommand(command: Command) {
        let description = command.commandShortDescription().padFront(totalLength: 20 - count(command.commandName()))
        println("- \(command.commandName())\(description)")
    }
    
}