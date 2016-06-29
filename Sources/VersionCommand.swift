//
//  VersionCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class VersionCommand: CommandType {
    
    public let name = "version"
    public let signature = ""
    public let shortDescription = "Prints the current version of this app"
    public let shortcut = "-v"
    
    public func execute(arguments: CommandArguments) throws  {
        print("Version: \(CLI.version)")
    }
    
}