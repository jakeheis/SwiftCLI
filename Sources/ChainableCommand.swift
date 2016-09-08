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
    
    public func withSignature(_ signature: String) -> ChainableCommand {
        self.signature = signature
        return self
    }
    
    public func withShortDescription(_ shortDescription: String) -> ChainableCommand {
        self.shortDescription = shortDescription
        return self
    }
    
    public func withShortcut(_ shortcut: String) -> ChainableCommand {
        self.shortcut = shortcut
        return self
    }
    
    public func withOptionsSetup(_ optionsSetup: @escaping OptionsSetupBlock) -> ChainableCommand {
        optionsSetupBlock = optionsSetup
        return self
    }
    
    public func withUnrecognizedOptionsPrintingBehavior(_ behavior: UnrecognizedOptionsPrintingBehavior) -> ChainableCommand {
        unrecognizedOptionsPrintingBehavior = behavior
        return self
    }
    
    public func withFailOnUnrecognizedOptions(_ shouldFail: Bool) -> ChainableCommand {
        failOnUnrecognizedOptions = shouldFail
        return self
    }
    
    public func withExecutionBlock(_ execution: @escaping ExecutionBlock) -> ChainableCommand {
        executionBlock = execution
        return self
    }
    
}
