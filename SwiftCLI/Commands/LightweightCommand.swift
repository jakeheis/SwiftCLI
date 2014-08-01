//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

typealias CommandExecutionBlock = ((arguments: NSDictionary, options: Options) -> (Bool, NSError?))

class LightweightCommand: Command {
    
    var lightweightCommandName: String = ""
    var lightweightCommandSignature: String = ""
    var lightweightCommandShortDescription: String = ""
    var lightweightExecutionBlock: CommandExecutionBlock? = nil
    
    var strictOnOptions = true
    var lightweightAcceptableFlags: [String] = []
    var lightweightAcceptableOptions: [String] = []
    
    init()  {
        super.init()
    }

    override func commandName() -> String  {
        return self.lightweightCommandName
    }
    
    override func commandSignature() -> String  {
        return self.lightweightCommandSignature
    }
    
    override func commandShortDescription() -> String  {
        return self.lightweightCommandShortDescription
    }
    
    override func handleOptions()  {
        if self.strictOnOptions {
            self.options.handleAll()
            return
        }
        
        for flag in self.lightweightAcceptableFlags {
            self.options.onFlag(flag, block: nil)
        }
        
        for option in self.lightweightAcceptableOptions {
            self.options.onOption(option, block: nil)
        }
    }

    override func execute() -> (success: Bool, error: NSError?) {
        return self.lightweightExecutionBlock!(arguments: self.arguments, options: self.options)
    }
}

