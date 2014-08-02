//
//  VersionCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class VersionCommand: Command {
    
    var version = "1.0"
    
    init()  {
        super.init()
    }
    
    override func commandName() -> String  {
        return "version"
    }
    
    override func commandShortDescription() -> String  {
        return "Prints the current version of this app"
    }
    
    override func commandShortcut() -> String?  {
        return "-v"
    }
    
    override func handleOptions()  {
        self.options.handleAll()
    }
    
    override func execute() -> (Bool, String?)  {
        println("Version: \(self.version)")
        
        return (true, nil)
    }
    
}