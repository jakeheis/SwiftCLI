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
    
    var paramType: Any.Type { get }
    
    func update(value: String) -> UpdateResult
    func signature(for name: String) -> String
}

protocol RequiredParameter: AnyParameter {
    associatedtype Value
    
    var value: Value { get }
}

extension RequiredParameter {
    public var required: Bool { return true }
    
    public var paramType: Any.Type {
        return Value.self
    }
}

protocol OptParameter: AnyParameter {
    associatedtype Value
    
    var value: Value? { get }
}

extension OptParameter {
    var required: Bool { return false }
    
    public var paramType: Any.Type {
        return Value.self
    }
}

// MARK: - Single parameters

public class Parameter: RequiredParameter {
    
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
    
    public func update(value: String) -> UpdateResult {
        satisfied = true
        privateValue = value
        return .success
    }
    
    public func signature(for name: String) -> String {
        return "<\(name)>"
    }

}

public class OptionalParameter: OptParameter {
    
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
    
    public func update(value: String) -> UpdateResult {
        self.value = value
        return .success
    }
    
    public func signature(for name: String) -> String {
        return "[<\(name)>]"
    }
    
}

// MARK: - Collected parameters

public protocol AnyCollectedParameter: AnyParameter {}

protocol RequiredCollectedParameter: AnyCollectedParameter {
    associatedtype Value
    
    var value: [Value] { get }
}

extension RequiredCollectedParameter {
    public var required: Bool { return true }
    
    public var paramType: Any.Type {
        return Value.self
    }
}

protocol OptCollectedParameter: AnyCollectedParameter {
    associatedtype Value
    
    var value: [Value] { get }
}

extension OptCollectedParameter {
    var required: Bool { return false }
    
    public var paramType: Any.Type {
        return Value.self
    }
}

public class CollectedParameter: RequiredCollectedParameter {
    
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
    
    public func update(value: String) -> UpdateResult {
        satisfied = true
        self.value.append(value)
        return .success
    }
    
    public func signature(for name: String) -> String {
        return "<\(name)> ..."
    }

}

public class OptionalCollectedParameter: OptCollectedParameter {
    
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
    
    public func update(value: String) -> UpdateResult {
        self.value.append(value)
        return .success
    }
    
    public func signature(for name: String) -> String {
        return "[<\(name)>] ..."
    }
    
}

// MARK: - ParameterIterator

public class ParameterIterator {
    
    private var params: [(String, AnyParameter)]
    private let collected: (String, AnyCollectedParameter)?
    
    public let minCount: Int
    public let maxCount: Int?
    
    public init(command: CommandPath) {
        var all = command.command.parameters
        
        self.minCount = all.filter({ $0.1.required }).count
        
        if let collected = all.last as? (String, AnyCollectedParameter) {
            self.collected = collected
            all.removeLast()
            self.maxCount = nil
        } else {
            self.collected = nil
            self.maxCount = all.count
        }
        
        self.params = all
        
        assert(all.index(where: { $0.1 is AnyCollectedParameter }) == nil, "can only have one collected parameter, and it must be the last parameter")
        assert(all.index(where: { $0.1 is OptionalParameter }).flatMap({ $0 >= minCount }) ?? true, "optional parameters must come after all required parameters")
    }
    
    public func nextIsCollection() -> Bool {
        return params.isEmpty && collected != nil
    }

    public func next() -> (String, AnyParameter)? {
        if let individual = params.first {
            params.removeFirst()
            return individual
        }
        if let (name, param) = collected {
            return (name, param)
        }
        return nil
    }
    
}

