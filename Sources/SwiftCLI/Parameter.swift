//
//  Parameter.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

public protocol AnyParameter: AnyValueBox {
    var required: Bool { get }
    var satisfied: Bool { get }

    func signature(for name: String) -> String
}

public enum Param {
    
    public class Required<Value: ConvertibleFromString>: AnyParameter, ValueBox {
        
        public let required = true
        public var satisfied: Bool { return privateValue != nil }
        public let completion: Completion
        public let validation: [Validation<Value>]
        
        private var privateValue: Value? = nil
        
        public var value: Value {
            return privateValue!
        }
        
        /// Creates a new required parameter
        ///
        /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
        public init(completion: Completion = .filename, validation: [Validation<Value>] = []) {
            self.completion = completion
            self.validation = validation
        }
        
        public func update(to value: Value) {
            privateValue = value
        }
        
        public func signature(for name: String) -> String {
            return "<\(name)>"
        }
        
    }
    
    public class Optional<Value: ConvertibleFromString>: AnyParameter, SingleValueBox {
        
        public let required = false
        public let satisfied = true
        public let completion: Completion
        public let validation: [Validation<Value>]
        
        public var value: Value? = nil
        
        /// Creates a new optional parameter
        ///
        /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
        public init(completion: Completion = .filename, validation: [Validation<Value>] = []) {
            self.completion = completion
            self.validation = validation
        }
        
        public func signature(for name: String) -> String {
            return "[<\(name)>]"
        }
        
    }
    
}

public protocol AnyCollectedParameter: AnyParameter {}
//protocol TypedCollectedParameter: AnyCollectedParameter, TypedParameter {}

public enum CollectedParam {
    
    public class Required<Value: ConvertibleFromString>: AnyCollectedParameter, MultiValueBox {
        
        public let required = true
        public var satisfied: Bool { return !value.isEmpty }
        public let completion: Completion
        public let validation: [Validation<Value>]
        
        public var value: [Value] = []
        
        /// Creates a new required collected parameter; must be last parameter in the command
        ///
        /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
        public init(completion: Completion = .filename, validation: [Validation<Value>] = []) {
            self.completion = completion
            self.validation = validation
        }
        
        public func signature(for name: String) -> String {
            return "<\(name)> ..."
        }
        
    }
    
    public class Optional<Value: ConvertibleFromString>: AnyCollectedParameter, MultiValueBox {
        
        public let required = false
        public let satisfied = true
        public let completion: Completion
        public let validation: [Validation<Value>]
        
        public var value: [Value] = []
        
        /// Creates a new optional collected parameter; must be last parameter in the command
        ///
        /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
        public init(completion: Completion = .filename, validation: [Validation<Value>] = []) {
            self.completion = completion
            self.validation = validation
        }
        
        public func signature(for name: String) -> String {
            return "[<\(name)>] ..."
        }
        
    }
    
}

public typealias Parameter = Param.Required<String>
public typealias OptionalParameter = Param.Optional<String>
public typealias CollectedParameter = CollectedParam.Required<String>
public typealias OptionalCollectedParameter = CollectedParam.Optional<String>

// MARK: - NamedParameter

public struct NamedParameter {
    public let name: String
    public let param: AnyParameter
    
    public var signature: String {
        return param.signature(for: name)
    }
    
    public init(name: String, param: AnyParameter) {
        self.name = name
        self.param = param
    }
}

// MARK: - ParameterIterator

public class ParameterIterator {
    
    private var params: [NamedParameter]
    private let collected: NamedParameter?
    
    public let minCount: Int
    public let maxCount: Int?
    
    public init(command: CommandPath) {
        var all = command.command.parameters
        
        self.minCount = all.filter({ $0.param.required }).count
        
        if let collected = all.last, collected.param is AnyCollectedParameter {
            self.collected = collected
            all.removeLast()
            self.maxCount = nil
        } else {
            self.collected = nil
            self.maxCount = all.count
        }
        
        self.params = all
        
        assert(all.index(where: { $0.param is AnyCollectedParameter }) == nil, "can only have one collected parameter, and it must be the last parameter")
        assert(all.index(where: { $0.param is OptionalParameter }).flatMap({ $0 >= minCount }) ?? true, "optional parameters must come after all required parameters")
    }
    
    public func nextIsCollection() -> Bool {
        return params.isEmpty && collected != nil
    }

    public func next() -> NamedParameter? {
        if let individual = params.first {
            params.removeFirst()
            return individual
        }
        return collected
    }
    
}

