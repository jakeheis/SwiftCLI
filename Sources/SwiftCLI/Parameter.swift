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

protocol ParameterPropertyWrapper {}

extension CLI {
    
    @propertyWrapper
    public class Param<Value: ConvertibleFromString> : _Param<Value>, AnyParameter, ValueBox, ParameterPropertyWrapper {
        
        public let required = true
        public var satisfied = false // This should be an error, find out why it's not failing tests
        
        private var privValue: Value?
        public var wrappedValue: Value {
            guard let val = privValue else {
                fatalError("cannot access parameter value outside of 'execute' func")
            }
            return val
        }
        public var value: Value { wrappedValue }
        
        public var projectedValue: Param {
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
            self.privValue = value
        }
        
    }
    
    @propertyWrapper
    public class OptParam<Value: ConvertibleFromString> : _Param<Value>, AnyParameter, ValueBox, ParameterPropertyWrapper {
        
        public let required = false
        public var satisfied = true
        
        public var wrappedValue: Value?
        public var value: Value? { wrappedValue }
        
        public var projectedValue: OptParam {
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
            self.wrappedValue = value
        }
        
    }
}

public enum Param {
    @available(*, unavailable, message: "Use CLI.Param instead")
    public class Required<Value: ConvertibleFromString>: _Param<Value>, AnyParameter, ValueBox {
        public let required = true
        public var satisfied = true
        public func update(to value: Value) {}
    }
    
    @available(*, unavailable, message: "Use CLI.OptParam instead")
    public class Optional<Value: ConvertibleFromString>: _Param<Value>, AnyParameter, ValueBox {
        public let required = false
        public let satisfied = true
        public func update(to value: Value) {}
    }
}

public protocol AnyCollectedParameter: AnyParameter {}

public enum CollectedParam {
    
    public class Required<Value: ConvertibleFromString>: _Param<Value>, AnyCollectedParameter, ValueBox {
        public let required = true
        public var satisfied: Bool { return !value.isEmpty }
        
        public var value: [Value] = []
        
        public func update(to value: Value) {
            self.value.append(value)
        }
    }
    
    public class Optional<Value: ConvertibleFromString>: _Param<Value>, AnyCollectedParameter, ValueBox {
        public let required = false
        public let satisfied = true
        
        public var value: [Value] = []
        
        public func update(to value: Value) {
            self.value.append(value)
        }
    }
    
}

public typealias Parameter = CLI.Param<String>
public typealias OptionalParameter = CLI.OptParam<String>
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
        if param is AnyCollectedParameter {
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
        
        if let collected = all.last, collected.param is AnyCollectedParameter {
            self.collected = collected
            all.removeLast()
            self.maxCount = nil
        } else {
            self.collected = nil
            self.maxCount = all.count
        }
        
        self.params = all
        
        assert(all.firstIndex(where: { $0.param is AnyCollectedParameter }) == nil, "can only have one collected parameter, and it must be the last parameter")
        assert(all.firstIndex(where: { $0.param is OptionalParameter }).flatMap({ $0 >= minCount }) ?? true, "optional parameters must come after all required parameters")
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

