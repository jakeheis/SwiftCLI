//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

/// Can be instantiated and configured as a fully functional command rather
/// than manually implementing Command.
public class LightweightCommand: Command {
    
    public var name: String = ""
    public var shortDescription: String = ""
    public var arguments: [(String, AnyArgument)] = []
    
    public var failOnUnrecognizedOptions = true
    
    public typealias Execution = (_ arguments: [String: AnyArgument]) throws -> ()
    public typealias OptionsSetup = (_ options: OptionRegistry) -> ()
    
    public var executionBlock: Execution? = nil
    public var optionsSetupBlock: OptionsSetup? = nil
    
    public init(name: String) {
        self.name = name
    }
    
    public func setupOptions(options: OptionRegistry) {
        optionsSetupBlock?(options)
    }
    
    public func execute() throws {
        var dict: [String: AnyArgument] = [:]
        for arg in arguments {
            dict[arg.0] = arg.1
        }
        try executionBlock?(dict)
    }
    
}
