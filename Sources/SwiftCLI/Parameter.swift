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

// MARK: - Single parameters

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
    public var value: [String] = []
    
    public init() {}
    
    open func update(value: [String]) {
        self.value = value
    }
    
    public func update(value: String) {
        self.value.append(value)
    }
    
    open func signature(for name: String) -> String {
        return "[<\(name)>] ..."
    }
    
}

// MARK: - ParameterIterator

public class ParameterIterator: IteratorProtocol {
    
    var params: [AnyParameter]
    let collected: AnyCollectedParameter?
    
    private let minCount: Int
    private let maxCount: Int?
    
    init(command: Command) {
        var all = command.parameters.map({ $0.1 })
        
        self.minCount = all.filter({ $0.required }).count
        
        if let collected = all.last as? AnyCollectedParameter {
            self.collected = collected
            all.removeLast()
            self.maxCount = nil
        } else {
            self.collected = nil
            self.maxCount = all.count
        }
        
        self.params = all
        
        assert(all.index(where: { $0 is AnyCollectedParameter }) == nil, "can only have one collected parameter, and it must be the last parameter")
        assert(all.index(where: { $0 is OptionalParameter }).flatMap({ $0 >= minCount }) ?? true, "optional parameters must come after all required parameters")
    }
    
    public func next() -> AnyParameter? {
        if let individual = params.first {
            params.removeFirst()
            return individual
        }
        return collected
    }
    
    public func createErrorMessage() -> String {
        let plural = minCount == 1 ? "argument" : "arguments"
        
        switch maxCount {
        case nil:
            return "error: command requires at least \(minCount) \(plural)"
        case let count? where count == minCount:
            return "error: command requires exactly \(count) \(plural)"
        case let count?:
            return "error: command requires between \(minCount) and \(count) arguments"
        }
    }
    
}

