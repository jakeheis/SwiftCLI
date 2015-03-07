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
        lightweightCommandSignature = signature
        return self
    }
    
    func withShortDescription(shortDescription: String) -> ChainableCommand {
        lightweightCommandShortDescription = shortDescription
        return self
    }
    
    func withShortcut(shortcut: String) -> ChainableCommand {
        lightweightCommandShortcut = shortcut
        return self
    }
    
    // MARK: - Options
    
    func withFlagsHandled(flags: [String], usage: String, block: OptionsFlagBlock?) -> ChainableCommand {
        handleFlags(flags, usage: usage, block: block)
        return self
    }
    
    func withKeysHandled(keys: [String], usage: String = "", valueSignature: String = "value", block: OptionsKeyBlock?) -> ChainableCommand {
        handleKeys(keys, usage: usage, valueSignature: valueSignature, block: block)
        return self
    }
    
    func withNoHelpShownOnHFlag() -> ChainableCommand {
        shouldShowHelpOnHFlag = false
        return self
    }
    
    func withPrintingBehaviorOnUnrecgonizedOptions(behavior: UnrecognizedOptionsPrintingBehavior) -> ChainableCommand {
        printingBehaviorOnUnrecognizedOptions = behavior
        return self
    }
    
    func withAllFlagsAndOptionsAllowed() -> ChainableCommand {
        shouldFailOnUnrecognizedOptions = false
        return self
    }
    
    // MARK: - Execution
    
    func withExecutionBlock(execution: CommandExecutionBlock) -> ChainableCommand {
        lightweightExecutionBlock = execution
        return self
    }
    
}