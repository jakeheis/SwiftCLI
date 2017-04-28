//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

/// Can be instantiated and configured as a fully functional command rather
/// than manually implementing Command.
@available(*, deprecated, message: "Implement Command on a custom type instead")
public class LightweightCommand: Command {
    
    public typealias Execution = (_ parameters: ParameterWrapper) throws -> ()
    
    public var name: String = ""
    public var shortDescription: String = ""
    public var parameters: [(String, AnyParameter)] = []
    public var options: [Option] = []
    public var execution: Execution? = nil
    
    public init(name: String) {
        self.name = name
    }
    
    public func execute() throws {
        try execution?(ParameterWrapper(params: parameters))
    }
    
}

// MARK: - ParameterWrapper

public class ParameterWrapper {
    
    private let parameters: [String: AnyParameter]
    
    init(params: [(String, AnyParameter)]) {
        var dict: [String: AnyParameter] = [:]
        for param in params {
            dict[param.0] = param.1
        }
        parameters = dict
    }
    
    public func required(_ name: String) -> String {
        return (parameters[name] as! Parameter).value
    }
    
    public func optional(_ name: String) -> String? {
        return (parameters[name] as! OptionalParameter).value
    }
    
    public func colllected(_ name: String) -> [String] {
        return (parameters[name] as! CollectedParameter).value
    }
    
    public func optionalColllected(_ name: String) -> [String]? {
        return (parameters[name] as! OptionalCollectedParameter).value
    }
    
}
