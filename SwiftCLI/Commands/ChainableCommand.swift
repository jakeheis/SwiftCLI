//
//  ChainableCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class ChainableCommand: LightweightCommand {
    
    init()  {
        super.init()
    }
    
    init(commandName: String) {
        super.init(commandName: commandName)
    }
 
    func withSignature(signature: String) -> ChainableCommand {
        self.lightweightCommandSignature = signature
        return self
    }
    
    func withShortDescription(shortDescription: String) -> ChainableCommand {
        self.lightweightCommandShortDescription = shortDescription
        return self
    }
    
    func withShortcut(shortcut: String) -> ChainableCommand {
        self.lightweightCommandShortcut = shortcut
        return self
    }
    
    func allowFlags(flags: [String]) -> ChainableCommand {
        self.lightweightAcceptableFlags = flags
        return self
    }
    
    func allowOptions(options: [String]) -> ChainableCommand {
        self.lightweightAcceptableOptions = options
        return self
    }
    
    func allowAllFlagsAndOptions() -> ChainableCommand {
        self.strictOnOptions = false
        return self
    }
    
    func onExecution(execution: CommandExecutionBlock) -> ChainableCommand {
        self.lightweightExecutionBlock = execution
        return self
    }
    
}