//
//  VersionCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class VersionCommand: Command {
    
    override public func commandName() -> String  {
        return "version"
    }
    
    override public func commandShortDescription() -> String  {
        return "Prints the current version of this app"
    }
    
    override public func commandShortcut() -> String?  {
        return "-v"
    }
    
    override public func execute() -> ExecutionResult  {
        println("Version: \(CLI.appVersion())")
        
        return success()
    }
    
}