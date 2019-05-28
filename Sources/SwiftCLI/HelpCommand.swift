//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class HelpCommand: Command {
    
    public let name = "help"
    public let shortDescription = "Prints help information"
    
    public let command = OptionalCollectedParameter(completion: .none)
    
    let cli: CLI
    
    init(cli: CLI) {
        self.cli = cli
    }
    
    public func execute() throws {
        var path = CommandGroupPath(top: cli)
        
        for pathSegment in command.value {
            let child = path.bottom.children.first(where:  { $0.name == pathSegment })
            if let group = child as? CommandGroup {
                path = path.appending(group)
            } else if let command = child as? Command {
                cli.helpMessageGenerator.writeUsageStatement(for: path.appending(command), to: stdout)
                return
            } else {
                break
            }
        }
        
        cli.helpMessageGenerator.writeCommandList(for: path, to: stdout)
    }
    
}
