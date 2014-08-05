//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class HelpCommand: Command {
    
    var allCommands: [Command] = []
    
    override func commandName() -> String  {
        return "help"
    }
    
    override func commandShortDescription() -> String  {
        return "Prints this help information"
    }
    
    override func commandShortcut() -> String?  {
        return "-h"
    }
    
    override func showHelpOnHFlag() -> Bool  {
        return false
    }
    
    override func failOnUnrecognizedOptions() -> Bool  {
        return false
    }
    
    override func execute() -> CommandResult  {
        println("\(CLI.appDescription())\n")
        println("Available commands: ")

        for command in self.allCommands {
            self.printCommand(command)
        }
        
        self.printCommand(self)
        
        return .Success
    }
    
    func printCommand(command: Command) {
        let str = self.padString(command.commandShortDescription(), toLength: 20, firstComponent: command.commandName())
        println("- \(command.commandName())\(str)")
    }
    
}