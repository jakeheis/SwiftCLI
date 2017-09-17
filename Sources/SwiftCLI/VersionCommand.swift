//
//  VersionCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class VersionCommand: Command {
    
    public let name = "version"
    public let shortDescription = "Prints the current version of this app"
    
    let version: String
    
    init(version: String) {
        self.version = version
    }
    
    public func execute() throws  {
        stdout <<< "Version: \(version)"
    }
    
}
