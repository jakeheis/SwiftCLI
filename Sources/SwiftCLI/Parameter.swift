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
    var collected: Bool { get }
}

public class _Param<Value: ConvertibleFromString> {
    
    public let completion: ShellCompletion
    public let validation: [Validation<Value>]
    
    /// Creates a new parameter
    ///
    /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
    public init(completion: ShellCompletion = .filename, validation: [Validation<Value>] = []) {
        self.completion = completion
        self.validation = validation
    }
    
}

public enum Param {
    
    @propertyWrapper
    public class Required<Value: ConvertibleFromString> : _Param<Value>, AnyParameter, ValueBox {
        
        public let required = true
        public var satisfied: Bool { privValue != nil }
        public let collected = false
        
        private var privValue: Value?
        public var wrappedValue: Value {
            guard let val = privValue else {
                fatalError("cannot access parameter value outside of 'execute' func")
            }
            return val
        }
        public var value: Value { wrappedValue }
        public var projectedValue: Required { self }
        
        public init() {
            super.init()
        }
        
        public override init(completion: ShellCompletion = .filename, validation: [Validation<Value>] = []) {
            super.init(completion: completion, validation: validation)
        }
        
        public init(completion: ShellCompletion = .filename, validation: Validation<Value>...) {
            super.init(completion: completion, validation: validation)
        }
        
        public func update(to value: Value) {
            self.privValue = value
        }
        
    }
    
    @propertyWrapper
    public class Optional<Value: ConvertibleFromString> : _Param<Value>, AnyParameter, ValueBox {
        
        public let required = false
        public var satisfied = true
        public let collected = false
        
        public private(set) var wrappedValue: Value?
        public var value: Value? { wrappedValue }
        public var projectedValue: Optional { self }
        
        public init() {
            super.init()
        }
        
        public override init(completion: ShellCompletion = .filename, validation: [Validation<Value>] = []) {
            super.init(completion: completion, validation: validation)
        }
        
        public init(completion: ShellCompletion = .filename, validation: Validation<Value>...) {
            super.init(completion: completion, validation: validation)
        }
        
        public func update(to value: Value) {
            self.wrappedValue = value
        }
        
    }
    
}

public enum CollectedParam {
    
    @propertyWrapper
    public class Required<Value: ConvertibleFromString> : _Param<Value>, AnyParameter, ValueBox {
        
        public let required = true
        public var satisfied: Bool { !value.isEmpty }
        public let collected = true
        
        public private(set) var wrappedValue: [Value] = []
        public var value: [Value] { wrappedValue }
        public var projectedValue: Required {
            return self
        }
        
        public init() {
            super.init()
        }
        
        public override init(completion: ShellCompletion = .filename, validation: [Validation<Value>] = []) {
            super.init(completion: completion, validation: validation)
        }
        
        public init(completion: ShellCompletion = .filename, validation: Validation<Value>...) {
            super.init(completion: completion, validation: validation)
        }
        
        public func update(to value: Value) {
            self.wrappedValue.append(value)
        }
        
    }
    
    @propertyWrapper
    public class Optional<Value: ConvertibleFromString> : _Param<Value>, AnyParameter, ValueBox {
        
        public let required = false
        public let satisfied = true
        public let collected = true
               
        public private(set) var wrappedValue: [Value] = []
        public var value: [Value] { wrappedValue }
        public var projectedValue: Optional {
            return self
        }
        
        public init() {
            super.init()
        }
        
        public override init(completion: ShellCompletion = .filename, validation: [Validation<Value>] = []) {
            super.init(completion: completion, validation: validation)
        }
        
        public init(completion: ShellCompletion = .filename, validation: Validation<Value>...) {
            super.init(completion: completion, validation: validation)
        }
        
        public func update(to value: Value) {
            self.wrappedValue.append(value)
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
        var sig = "<\(name)>"
        if param.required == false {
            sig = "[\(sig)]"
        }
        if param.collected {
            sig += " ..."
        }
        return sig
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
        
        if let collected = all.last, collected.param.collected {
            self.collected = collected
            all.removeLast()
            self.maxCount = nil
        } else {
            self.collected = nil
            self.maxCount = all.count
        }
        
        self.params = all
        
        assert(all.firstIndex(where: { $0.param.collected }) == nil, "can only have one collected parameter, and it must be the last parameter")
        assert(all.firstIndex(where: { !$0.param.required }).flatMap({ $0 >= minCount }) ?? true, "optional parameters must come after all required parameters")
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

