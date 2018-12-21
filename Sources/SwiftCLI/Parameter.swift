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
    var completion: Completion { get }
    
    var valueType: Any.Type { get }
    
    func update(value: String) -> UpdateResult
    func signature(for name: String) -> String
}

public enum Param {
    
    public class Required<Value: ConvertibleFromString>: AnyParameter {
        
        public let required = true
        public var satisfied: Bool { return privateValue != nil }
        public let completion: Completion
        
        public var valueType: Any.Type { return Value.self }
        
        private var privateValue: Value? = nil
        
        public var value: Value {
            return privateValue!
        }
        
        /// Creates a new required parameter
        ///
        /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
        public init(completion: Completion = .filename) {
            self.completion = completion
        }
        
        public func update(value: String) -> UpdateResult {
            guard let converted = Value.convert(from: value) else {
                return .conversionError
            }
            privateValue = converted
            return .success
        }
        
        public func signature(for name: String) -> String {
            return "<\(name)>"
        }
        
    }
    
    public class Optional<Value: ConvertibleFromString>: AnyParameter {
        
        public let required = false
        public let satisfied = true
        public let completion: Completion
        
        public var valueType: Any.Type {
            return Value.self
        }
        
        public var value: Value? = nil
        
        /// Creates a new optional parameter
        ///
        /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
        public init(completion: Completion = .filename) {
            self.completion = completion
        }
        
        public func update(value: String) -> UpdateResult {
            guard let converted = Value.convert(from: value) else {
                return .conversionError
            }
            self.value = converted
            return .success
        }
        
        public func signature(for name: String) -> String {
            return "[<\(name)>]"
        }
        
    }
    
}

public protocol AnyCollectedParameter: AnyParameter {}

public enum CollectedParam {
    
    public class Required<Value: ConvertibleFromString>: AnyCollectedParameter {
        
        public let required = true
        public var satisfied: Bool { return !value.isEmpty }
        public let completion: Completion
        
        public var valueType: Any.Type {
            return Value.self
        }
        
        public var value: [Value] = []
        
        /// Creates a new required collected parameter; must be last parameter in the command
        ///
        /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
        public init(completion: Completion = .filename) {
            self.completion = completion
        }
        
        public func update(value: String) -> UpdateResult {
            guard let converted = Value.convert(from: value) else {
                return .conversionError
            }
            self.value.append(converted)
            return .success
        }
        
        public func signature(for name: String) -> String {
            return "<\(name)> ..."
        }
        
    }
    
    public class Optional<Value: ConvertibleFromString>: AnyCollectedParameter {
        
        public let required = false
        public let satisfied = true
        public let completion: Completion
        
        public var valueType: Any.Type {
            return Value.self
        }
        
        public var value: [Value] = []
        
        /// Creates a new optional collected parameter; must be last parameter in the command
        ///
        /// - Parameter completion: the completion type for use in ZshCompletionGenerator; default .filename
        public init(completion: Completion = .filename) {
            self.completion = completion
        }
        
        public func update(value: String) -> UpdateResult {
            guard let converted = Value.convert(from: value) else {
                return .conversionError
            }
            self.value.append(converted)
            return .success
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
}

// MARK: - CustomParameterValue

public protocol CustomParameterValue: ConvertibleFromString {
    static func errorMessage(namedParameter: NamedParameter) -> String
}

#if swift(>=4.2)

public extension CustomParameterValue where Self: CaseIterable {
    
    static func errorMessage(namedParameter: NamedParameter) -> String {
        let options = allCases.map({ String(describing: $0) }).joined(separator: ", ")
        return "illegal value passed to '\(namedParameter.name)'; expected one of: \(options)"
    }
    
}

#endif

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

