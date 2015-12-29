//
//  ChainableCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

/// A chainable interface to a CommandType; all functions return the object itself for easy chaining.
/// Should only be used for simple commands.
public class ChainableCommand: LightweightCommand {
    
    public override init(commandName: String) {
        super.init(commandName: commandName)
    }
    
    public func withSignature(signature: String) -> ChainableCommand {
        commandSignature = signature
        return self
    }
    
    public func withShortDescription(shortDescription: String) -> ChainableCommand {
        commandShortDescription = shortDescription
        return self
    }
    
    public func withShortcut(shortcut: String) -> ChainableCommand {
        commandShortcut = shortcut
        return self
    }
    
    public func withOptionsSetup(optionsSetup: OptionsSetupBlock) -> ChainableCommand {
        optionsSetupBlock = optionsSetup
        return self
    }
    
    public func withUnrecognizedOptionsPrintingBehavior(behavior: UnrecognizedOptionsPrintingBehavior) -> ChainableCommand {
        unrecognizedOptionsPrintingBehavior = behavior
        return self
    }
    
    public func withFailOnUnrecognizedOptions(shouldFail: Bool) -> ChainableCommand {
        failOnUnrecognizedOptions = shouldFail
        return self
    }
    
    public func withExecutionBlock(execution: ExecutionBlock) -> ChainableCommand {
        executionBlock = execution
        return self
    }
    
}