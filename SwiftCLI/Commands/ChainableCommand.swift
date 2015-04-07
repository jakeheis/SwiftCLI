//
//  ChainableCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class ChainableCommand: LightweightCommand {
    
    override init(commandName: String) {
        super.init(commandName: commandName)
    }
    
    public func withSignature(signature: String) -> ChainableCommand {
        lightweightCommandSignature = signature
        return self
    }
    
    public func withShortDescription(shortDescription: String) -> ChainableCommand {
        lightweightCommandShortDescription = shortDescription
        return self
    }
    
    public func withShortcut(shortcut: String) -> ChainableCommand {
        lightweightCommandShortcut = shortcut
        return self
    }
    
    // MARK: - Options
    
    public func withFlagsHandled(flags: [String], usage: String, block: FlagOption.FlagBlock?) -> ChainableCommand {
        handleFlags(flags, usage: usage, block: block)
        return self
    }
    
    public func withKeysHandled(keys: [String], usage: String = "", valueSignature: String = "value", block: KeyOption.KeyBlock?) -> ChainableCommand {
        handleKeys(keys, usage: usage, valueSignature: valueSignature, block: block)
        return self
    }
    
    public func withNoHelpShownOnHFlag() -> ChainableCommand {
        shouldShowHelpOnHFlag = false
        return self
    }
    
    public func withPrintingBehaviorOnUnrecgonizedOptions(behavior: UnrecognizedOptionsPrintingBehavior) -> ChainableCommand {
        printingBehaviorOnUnrecognizedOptions = behavior
        return self
    }
    
    public func withAllFlagsAndOptionsAllowed() -> ChainableCommand {
        shouldFailOnUnrecognizedOptions = false
        return self
    }
    
    // MARK: - Execution
    
    public func withExecutionBlock(execution: ExecutionBlock) -> ChainableCommand {
        lightweightExecutionBlock = execution
        return self
    }
    
}