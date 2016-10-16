//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class HelpCommand: OptionCommand {
    
    public let name = "help"
    public let signature = "[<opt>] ..."
    public let shortDescription = "Prints this help information"
    
    public let failOnUnrecognizedOptions = false
    public let unrecognizedOptionsPrintingBehavior = UnrecognizedOptionsPrintingBehavior.printNone
    public let helpOnHFlag = false
    
    public var allCommands: [Command] = []
    public var printCLIDescription = true
    
    public func setupOptions(options: OptionRegistry) {} // Don't actually do anything with any options
    
    public func execute(arguments: CommandArguments) throws {
        if printCLIDescription && !CLI.description.isEmpty {
            print("\(CLI.description)")
            print()
        }
        
        print("Available commands: ")

        for command in allCommands {
            printCommand(command)
        }
    }
    
    func printCommand(_ command: Command) {
        let spacing = String(repeating: " ", count: 20 - command.name.characters.count)
        print("- \(command.name)\(spacing)\(command.shortDescription)")
    }
    
}
