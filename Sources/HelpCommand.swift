//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class HelpCommand: Command {
    
    public let name = "help"
    public let shortDescription = "Prints this help information"
    
    public func execute() throws {
        let message = CLI.helpMessageGenerator.generateCommandList(
            prefix: CLI.name,
            description: CLI.description,
            routables: CLI.commands
        )
        print(message)
    }
    
}
