//
//  ChainableCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class ChainableCommand: LightweightCommand {
    
    override init(commandName: String) {
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
    
    // MARK: - Options
    
    func withFlagsHandled(flags: [String], block: OptionsFlagBlock?, usage: String) -> ChainableCommand {
        self.handleFlags(flags, block: block, usage: usage)
        return self
    }
    
    func withKeysHandled(keys: [String], block: OptionsKeyBlock?, usage: String = "", valueSignature: String = "value") -> ChainableCommand {
        self.handleKeys(keys, block: block, usage: usage, valueSignature: valueSignature)
        return self
    }
    
    func withNoHelpShownOnHFlag() -> ChainableCommand {
        self.shouldShowHelpOnHFlag = false
        return self
    }
    
    func withPrintingBehaviorOnUnrecgonizedOptions(behavior: UnrecognizedOptionsPrintingBehavior) -> ChainableCommand {
        self.printingBehaviorOnUnrecognizedOptions = behavior
        return self
    }
    
    func withAllFlagsAndOptionsAllowed() -> ChainableCommand {
        self.shouldFailOnUnrecognizedOptions = false
        return self
    }
    
    // MARK: - Execution
    
    func withExecutionBlock(execution: CommandExecutionBlock) -> ChainableCommand {
        self.lightweightExecutionBlock = execution
        return self
    }
    
}