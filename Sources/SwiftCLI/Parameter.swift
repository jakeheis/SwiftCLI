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

public enum Param {
    
    public class Required<Value: ConvertibleFromString>: AnyParameter {
        
        public let required = true
        private(set) public var satisfied = false
        public let completion: Completion
        
        private var privateValue: Value? = nil
        
        public var paramType: Any.Type {
            return Value.self
        }
        
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
            satisfied = true
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
        
        public var value: Value? = nil
        
        public var paramType: Any.Type {
            return Value.self
        }
        
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

public typealias Parameter = Param.Required<String>
public typealias OptionalParameter = Param.Optional<String>

public protocol AnyCollectedParameter: AnyParameter {}

public enum CollectedParam {
    
    public class Required<Value: ConvertibleFromString>: AnyCollectedParameter {
        
        public let required = true
        private(set) public var satisfied = false
        public let completion: Completion
        
        public var value: [Value] = []
        
        public var paramType: Any.Type {
            return Value.self
        }
        
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
            satisfied = true
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
        
        public var value: [Value] = []
        
        public var paramType: Any.Type {
            return Value.self
        }
        
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

public typealias CollectedParameter = CollectedParam.Required<String>
public typealias OptionalCollectedParameter = CollectedParam.Optional<String>

// MARK: - CustomParameterValue

public protocol CustomParameterValue: ConvertibleFromString {
    static func errorMessage(paramName: String, parameter: AnyParameter) -> String
}

public extension CustomParameterValue where Self: CaseIterable {
    
    static func errorMessage(paramName: String, parameter: AnyParameter) -> String {
        let options = allCases.map({ String(describing: $0) }).joined(separator: ", ")
        return "illegal value passed to '\(paramName)'; expected one of: \(options)"
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

