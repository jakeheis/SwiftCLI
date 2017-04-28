//
//  ChainableCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

/// A chainable interface to a CommandType; all functions return the object itself for easy chaining
@available(*, deprecated, message: "Implement Command on a custom type instead")
public class ChainableCommand: LightweightCommand {
    
    @discardableResult
    public func withParameter(named name: String) -> ChainableCommand {
        parameters.append((name, Parameter()))
        return self
    }
    
    @discardableResult
    public func withOptionalParameter(named name: String) -> ChainableCommand {
        parameters.append((name, OptionalParameter()))
        return self
    }
    
    @discardableResult
    public func withCollectedParameter(named name: String) -> ChainableCommand {
        parameters.append((name, CollectedParameter()))
        return self
    }
    
    @discardableResult
    public func withOptionalCollectedParameter(named name: String) -> ChainableCommand {
        parameters.append((name, OptionalCollectedParameter()))
        return self
    }
    
    @discardableResult
    public func withOption(_ option: Option) -> ChainableCommand {
        options.append(option)
        return self
    }
    
    @discardableResult
    public func withShortDescription(_ shortDescription: String) -> ChainableCommand {
        self.shortDescription = shortDescription
        return self
    }
    
    @discardableResult
    public func withExecution(_ execution: @escaping Execution) -> ChainableCommand {
        self.execution = execution
        return self
    }
    
}
