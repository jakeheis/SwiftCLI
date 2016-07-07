//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class HelpCommand: OptionCommandType {
    
    var allCommands: [CommandType] = []
    
    public let commandName = "help"
    public let commandSignature = "[<opt>]"
    public let commandShortDescription = "Prints this help information"
    public let commandShortcut = "-h"
    
    public let failOnUnrecognizedOptions = false
    public let unrecognizedOptionsPrintingBehavior = UnrecognizedOptionsPrintingBehavior.printOnlyUnrecognizedOptions
    public let helpOnHFlag = false
    
    public func setupOptions(_ options: Options) {} // Don't actually do anything with any options
    
    public func execute(_ arguments: CommandArguments) throws {
        if arguments.optionalArgument("opt") != nil {
            print("Usage: baker help\n")
        }
        
        print("\(CLI.appDescription)\n")
        print("Available commands: ")

        for command in allCommands {
            printCommand(command)
        }
        
        printCommand(self)
    }
    
    func printCommand(_ command: CommandType) {
        let description = command.commandShortDescription.padFront(20 - command.commandName.characters.count)
        print("- \(command.commandName)\(description)")
    }
    
}
