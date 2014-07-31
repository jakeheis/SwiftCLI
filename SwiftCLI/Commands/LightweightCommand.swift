//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

typealias CommandExecutionBlock = ((parameters: NSDictionary, options: Options) -> (Bool, NSError?))

class LightweightCommand: Command {
    
    var lightweightCommandName: String = ""
    var lightweightCommandSignature: String = ""
    var lightweightCommandShortDescription: String = ""
    var lightweightExecutionBlock: CommandExecutionBlock? = nil
    
    var strictOnOptions = true
    var lightweightAcceptableFlags: [String] = []
    var lightweightAcceptableOptions: [String] = []

    override var commandName: String {
        return self.lightweightCommandName
    }
    
    override func commandSignature() -> String  {
        return self.lightweightCommandSignature
    }
    
    override var commandShortDescription: String {
        return self.lightweightCommandShortDescription
    }
    
    override func handleOptions() -> Bool  {
        if self.strictOnOptions {
            self.options.handleAll()
            return true
        }
        
        for flag in self.lightweightAcceptableFlags {
            self.options.onFlag(flag, block: nil)
        }
        
        for option in self.lightweightAcceptableOptions {
            self.options.onOption(option, block: nil)
        }
        
        return super.handleOptions()
    }

    override func execute() -> (success: Bool, error: NSError?) {
        return self.lightweightExecutionBlock!(parameters: self.parameters, options: self.options)
    }
}

