//
//  CommandSignature.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/9/15.
//  Copyright © 2017 jakeheis. All rights reserved.
//

/// The command signature of a command
public class CommandSignature {
    
    public var required: [Parameter] = []
    public var optional: [OptionalParameter] = []
    public var collected: AnyCollectedParameter?
    
    public init(command: Command) {
        for (_, parameter) in command.parameters {
            assert(collected == nil, "The collection parameter must be the last parameter in the command")
            if let c = parameter as? AnyCollectedParameter {
                collected = c
            } else if let r = parameter as? Parameter {
                assert(optional.isEmpty, "All required parameters must come before optional parameters")
                required.append(r)
            } else if let o = parameter as? OptionalParameter {
                optional.append(o)
            } else {
                assertionFailure("Unrecognized parameter type")
            }
        }
    }
    
    public init(required: [Parameter], optional: [OptionalParameter], collected: AnyCollectedParameter?) {
        self.required = required
        self.optional = optional
        self.collected = collected
    }

}

public class ParameterIterator: IteratorProtocol {
    
    var params: [AnyParameter]
    let collected: AnyCollectedParameter?
    
    private let minCount: Int
    private let maxCount: Int?
    private var gotCount = 0
    
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
    }
    
    public func next() -> AnyParameter? {
        if let individual = params.first {
            params.removeFirst()
            gotCount += 1
            return individual
        }
        if let collected = collected {
            gotCount += 1
            return collected
        }
        return nil
    }
    
    public func errorMessage(got: Int) -> String {
        let plural = minCount == 1 ? "argument" : "arguments"
        
        switch maxCount {
        case nil:
            return "error: command requires at least \(minCount) \(plural), got \(got)"
        case let count? where count == minCount:
            return "error: command requires exactly \(count) \(plural), got \(got)"
        case let count?:
            return "error: command requires between \(minCount) and \(count) arguments, got \(got)"
        }
    }
    
}
