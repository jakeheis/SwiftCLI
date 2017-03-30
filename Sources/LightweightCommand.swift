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
    public var parameters: [(String, AnyParameter)] = []
    
    public var failOnUnrecognizedOptions = true
    
    public typealias Execution = (_ parameters: ParameterWrapper) throws -> ()
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
        try executionBlock?(ParameterWrapper(params: parameters))
    }
    
}

// MARK: - ParameterWrapper

public class ParameterWrapper {
    
    private let parameters: [String: AnyParameter]
    
    init(params: [(String, AnyParameter)]) {
        var dict: [String: AnyParameter]
        for param in params {
            dict[param.0] = param.1
        }
        parameters = dict
    }
    
    func required(_ name: String) -> String {
        return (parameters[name] as! Parameter).value
    }
    
    func optional(_ name: String) -> String? {
        return (parameters[name] as! OptionalParameter).value
    }
    
    func colllected(_ name: String) -> [String] {
        return (parameters[name] as! CollectedParameter).value
    }
    
    func optionalColllected(_ name: String) -> [String]? {
        return (parameters[name] as! OptionalCollectedParameter).value
    }
    
}
