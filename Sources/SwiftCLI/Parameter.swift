//
//  Parameter.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

public protocol AnyParameter: class {
    var required: Bool { get }
    var satisfied: Bool { get }
    
    func update(value: String)
    func signature(for name: String) -> String
}

open class Parameter: AnyParameter {
    
    public let required = true
    private(set) public var satisfied = false
    private var privateValue: String? = nil
    
    public var value: String {
        return privateValue!
    }

    public init() {}
    
    open func update(value: String) {
        satisfied = true
        privateValue = value
    }
    
    open func signature(for name: String) -> String {
        return "<\(name)>"
    }

}

open class OptionalParameter: AnyParameter {
    
    public let required = false
    public let satisfied = true
    public var value: String? = nil
    
    public init() {}
    
    open func update(value: String) {
        self.value = value
    }
    
    open func signature(for name: String) -> String {
        return "[<\(name)>]"
    }
    
}

// MARK: - Collected parameters

public protocol AnyCollectedParameter: AnyParameter {
    func update(value: [String])
}

//public class DynamicParameter: AnyCollectedParameter {
//
//    public let required: Bool
//    public let reaction: ([String]) -> ()
//
//    public init(required: Bool, reaction: @escaping ([String]) -> ()) {
//        self.required = required
//        self.reaction = reaction
//    }
//
//    public func update(value: [String]) {
//        reaction(value)
//    }
//
//    public func signature(for name: String) -> String {
//        return (required ? "<\(name)>" : "[<\(name)>]") + " ..."
//    }
//
//}

open class CollectedParameter: AnyCollectedParameter {
    
    public let required = true
    private(set) public var satisfied = false
    public var value: [String] = []
    
    public init() {}
    
    open func update(value: [String]) {
        satisfied = true
        self.value = value
    }
    
    public func update(value: String) {
        satisfied = true
        self.value.append(value)
    }
    
    open func signature(for name: String) -> String {
        return "<\(name)> ..."
    }

}

open class OptionalCollectedParameter: AnyCollectedParameter {
    
    public let required = false
    public let satisfied = true
    public var value: [String]? = nil
    
    public init() {}
    
    open func update(value: [String]) {
        self.value = value
    }
    
    public func update(value: String) {
        self.value?.append(value)
    }
    
    open func signature(for name: String) -> String {
        return "[<\(name)>] ..."
    }
    
}
