//
//  Parameter.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

public protocol AnyParameter {
    func signature(for name: String) -> String
}

open class Parameter: AnyParameter {
    
    private var privateValue: String? = nil
    
    public var value: String {
        return privateValue!
    }

    public init() {}
    
    open func update(value: String) {
        privateValue = value
    }
    
    open func signature(for name: String) -> String {
        return "<\(name)>"
    }

}

open class OptionalParameter: AnyParameter {
    
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
    var required: Bool { get }

    func update(value: [String])
}

open class CollectedParameter: AnyCollectedParameter {
    
    public let required = true
    public var value: [String] = []
    
    public init() {}
    
    open func update(value: [String]) {
        self.value = value
    }
    
    open func signature(for name: String) -> String {
        return "<\(name)> ..."
    }

}

open class OptionalCollectedParameter: AnyCollectedParameter {
    
    public let required = false
    public var value: [String]? = nil
    
    public init() {}
    
    open func update(value: [String]) {
        self.value = value
    }
    
    open func signature(for name: String) -> String {
        return "[<\(name)>] ..."
    }
    
}
