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

public class Parameter: AnyParameter {
    
    public let required = true
    private(set) public var satisfied = false
    private var privateValue: String? = nil
    
    public var value: String {
        return privateValue!
    }

    public init() {}
    
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
    public var value: String? = nil
    
    public init() {}
    
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
    public var value: [String] = []
    
    public init() {}
    
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
    public var value: [String] = []
    
    public init() {}
    
    public func update(value: String) {
        self.value.append(value)
    }
    
    public func signature(for name: String) -> String {
        return "[<\(name)>] ..."
    }
    
}

// MARK: - ParameterIterator

public class ParameterIterator {
    
    public let command: CommandPath
    
    private var params: [AnyParameter]
    private let collected: AnyCollectedParameter?
    
    private let minCount: Int
    private let maxCount: Int?
    
    public init(command: CommandPath) {
        self.command = command
        
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
    
    public func isCollecting() -> Bool {
        return params.isEmpty && collected != nil
    }
    
    public func parse(args: ArgumentList) throws {
        if let param = next() {
            param.update(value: args.pop())
        } else {
            throw ParameterError(command: command, message: createErrorMessage())
        }
    }
    
    public func finish() throws {
        if let param = next(), !param.satisfied {
            throw ParameterError(command: command, message: createErrorMessage())
        }
    }
    
    // MARK: - Helpers
    
    private func next() -> AnyParameter? {
        if let individual = params.first {
            params.removeFirst()
            return individual
        }
        return collected
    }
    
    private func createErrorMessage() -> String {
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

