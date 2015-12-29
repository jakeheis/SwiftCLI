//
//  VersionCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class VersionCommand: CommandType {
    
    public var commandName: String  {
        return "version"
    }
    
    public var commandSignature: String {
        return ""
    }
    
    public var commandShortDescription: String  {
        return "Prints the current version of this app"
    }
    
    public var commandShortcut: String?  {
        return "-v"
    }
    
    public func execute(arguments: CommandArguments) throws  {
        print("Version: \(CLI.appVersion)")
    }
    
}