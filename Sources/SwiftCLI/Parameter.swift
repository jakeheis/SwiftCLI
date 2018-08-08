//
//  Parameter.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

public enum Completion {
    case none
    case filename
    case values([(name: String, description: String)])
    case function(String)
}

public protocol AnyParameter: class {
    var required: Bool { get }
    var satisfied: Bool { get }
    var completion: Completion { get }
    
    func update(value: String)
    func signature(for name: String) -> String
}

// MARK: - Single parameters

public class Parameter: AnyParameter {
    
    public let required = true
    private(set) public var satisfied = false
    public let completion: Completion
    
    private var privateValue: String? = nil
    
    public var value: String {
        return privateValue!
    }

    /// Creates a new required parameter
    ///
    /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
    public init(completion: Completion = .filename) {
        self.completion = completion
    }
    
    public func update(value: String) {
        satisfied = true
        privateValue = value
    }
    
    public func signature(for name: String) -> String {
        return "<\(name)>"
    }

}

public class OptionalParameter: AnyParameter {
    
    public let required = false
    public let satisfied = true
    public let completion: Completion
    
    public var value: String? = nil
    
    /// Creates a new optional parameter
    ///
    /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
    public init(completion: Completion = .filename) {
        self.completion = completion
    }
    
    public func update(value: String) {
        self.value = value
    }
    
    public func signature(for name: String) -> String {
        return "[<\(name)>]"
    }
    
}

// MARK: - Collected parameters

public protocol AnyCollectedParameter: AnyParameter {}

public class CollectedParameter: AnyCollectedParameter {
    
    public let required = true
    private(set) public var satisfied = false
    public let completion: Completion
    
    public var value: [String] = []
    
    /// Creates a new required collected parameter; must be last parameter in the command
    ///
    /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
    public init(completion: Completion = .filename) {
        self.completion = completion
    }
    
    public func update(value: String) {
        satisfied = true
        self.value.append(value)
    }
    
    public func signature(for name: String) -> String {
        return "<\(name)> ..."
    }

}

public class OptionalCollectedParameter: AnyCollectedParameter {
    
    public let required = false
    public let satisfied = true
    public let completion: Completion
    
    public var value: [String] = []
    
    /// Creates a new optional collected parameter; must be last parameter in the command
    ///
    /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
    public init(completion: Completion = .filename) {
        self.completion = completion
    }
    
    public func update(value: String) {
        self.value.append(value)
    }
    
    public func signature(for name: String) -> String {
        return "[<\(name)>] ..."
    }
    
}

// MARK: - ParameterIterator

public class ParameterIterator {
    
    private var params: [AnyParameter]
    private let collected: AnyCollectedParameter?
    
    let minCount: Int
    let maxCount: Int?
    
    public init(command: CommandPath) {
        var all = command.command.parameters.map({ $0.1 })
        
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
    
    public func nextIsCollection() -> Bool {
        return params.isEmpty && collected != nil
    }

    public func next() -> AnyParameter? {
        if let individual = params.first {
            params.removeFirst()
            return individual
        }
        return collected
    }
    
}

