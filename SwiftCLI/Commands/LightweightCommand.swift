//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

typealias CommandExecutionBlock = ((arguments: NSDictionary, options: Options) -> (Bool, String?))

class LightweightCommand: Command {
    
    var lightweightCommandName: String = ""
    var lightweightCommandSignature: String = ""
    var lightweightCommandShortDescription: String = ""
    var lightweightCommandShortcut: String? = nil
    var lightweightExecutionBlock: CommandExecutionBlock? = nil
    
    var strictOnOptions = true
    var lightweightAcceptableFlags: [String] = []
    var lightweightAcceptableOptions: [String] = []
    
    init()  {
        super.init()
    }
    
    init(commandName: String) {
        super.init()
        
        lightweightCommandName = commandName
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
    
    override func commandShortcut() -> String?  {
        return self.lightweightCommandShortcut
    }
    
    override func handleOptions()  {
        for flag in self.lightweightAcceptableFlags {
            self.options.onFlag(flag, block: nil)
        }
        
        for option in self.lightweightAcceptableOptions {
            self.options.onKey(option, block: nil)
        }
    }
    
    override func failOnUnhandledOptions() -> Bool  {
        return self.strictOnOptions
    }

    override func execute() -> (Bool, String?) {
        return self.lightweightExecutionBlock!(arguments: self.arguments, options: self.options)
    }
}

