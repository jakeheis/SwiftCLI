//
//  VersionCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class VersionCommand: Command {
    
    public let name = "version"
    public let signature = ""
    public let shortDescription = "Prints the current version of this app"
    
    public func execute(arguments: CommandArguments) throws  {
        print("Version: \(CLI.version)")
    }
    
}
