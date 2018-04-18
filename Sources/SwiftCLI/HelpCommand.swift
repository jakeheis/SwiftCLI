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
    
    let cli: CLI
    
    init(cli: CLI) {
        self.cli = cli
    }
    
    public func execute() throws {
        cli.helpMessageGenerator.writeCommandList(for: CommandGroupPath(top: cli), to: stdout)
    }
    
}
