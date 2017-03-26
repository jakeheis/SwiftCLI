//
//  CommandArguments.swift
//  Example
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

public protocol Arg {
    var required: Bool { get }
    
    func signature(for name: String) -> String
}

public class Argument: Arg {
    
    public let required = true
    private var privateValue: String? = nil
    
    public var value: String {
        return privateValue!
    }

    public init() {}
    
    public func update(value: String) {
        privateValue = value
    }
    
    public func signature(for name: String) -> String {
        return "<\(name)>"
    }

}

public class OptionalArgument: Arg {
    
    public let required = false
    public var value: String? = nil
    
    public init() {}
    
    public func update(value: String) {
        self.value = value
    }
    
    public func signature(for name: String) -> String {
        return "[<\(name)>]"
    }
    
}

public protocol CollectedArg: Arg {
    func update(value: [String])
}

public class CollectedArgument: CollectedArg {
    
    public let required = true
    public var value: [String] = []
    
    public init() {}
    
    public func update(value: [String]) {
        self.value = value
    }
    
    public func signature(for name: String) -> String {
        return "<\(name)> ..."
    }

}

public class OptionalCollectedArgument: CollectedArg {
    
    public let required = false
    public var value: [String]? = nil
    
    public init() {}
    
    public func update(value: [String]) {
        self.value = value
    }
    
    public func signature(for name: String) -> String {
        return "[<\(name)>] ..."
    }
    
}
