//
//  ChainableCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

/// A chainable interface to a CommandType; all functions return the object itself for easy chaining
public class ChainableCommand: LightweightCommand {
    
    @discardableResult
    public func withArgument(named name: String) -> ChainableCommand {
        arguments.append((name, Argument()))
        return self
    }
    
    @discardableResult
    public func withOptionalArgument(named name: String) -> ChainableCommand {
        arguments.append((name, OptionalArgument()))
        return self
    }
    
    @discardableResult
    public func withCollectedArgument(named name: String) -> ChainableCommand {
        arguments.append((name, CollectedArgument()))
        return self
    }
    
    @discardableResult
    public func withOptionalCollectedArgument(named name: String) -> ChainableCommand {
        arguments.append((name, OptionalCollectedArgument()))
        return self
    }
    
    @discardableResult
    public func withShortDescription(_ shortDescription: String) -> ChainableCommand {
        self.shortDescription = shortDescription
        return self
    }
    
    @discardableResult
    public func withOptionsSetup(_ optionsSetup: @escaping OptionsSetup) -> ChainableCommand {
        optionsSetupBlock = optionsSetup
        return self
    }
    
    @discardableResult
    public func withFailOnUnrecognizedOptions(_ shouldFail: Bool) -> ChainableCommand {
        failOnUnrecognizedOptions = shouldFail
        return self
    }
    
    @discardableResult
    public func withExecution(_ execution: @escaping Execution) -> ChainableCommand {
        executionBlock = execution
        return self
    }
    
}
