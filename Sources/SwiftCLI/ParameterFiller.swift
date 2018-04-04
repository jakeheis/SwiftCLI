//
//  ParameterFiller.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - ParameterFiller

/// Protcol representing an object which parses the arguments for a command from an argument list
public protocol ParameterFiller {
    func fillParameters(of signature: CommandSignature, with arguments: ArgumentList) throws
}

// MARK: - DefaultParameterFiller

public class DefaultParameterFiller: ParameterFiller {
    
    public init() {}
    
    public func fillParameters(of signature: CommandSignature, with arguments: ArgumentList) throws {
        let gotCount = arguments.count()
        
        // First satisfy required parameters
        for parameter in signature.required {
            guard let next = arguments.head else {
                throw wrongArgCount(signature: signature, got: gotCount)
            }
            parameter.update(value: next.value)
            arguments.remove(node: next)
        }
        
        // Then optional parameters
        for parameter in signature.optional {
            guard let next = arguments.head else {
                break
            }
            parameter.update(value: next.value)
            arguments.remove(node: next)
        }
        
        // Finally collect remaining arguments if need be
        if let collected = signature.collected {
            var last: [String] = []
            while let node = arguments.head {
                last.append(node.value)
                arguments.remove(node: node)
            }
            if last.isEmpty {
                if collected.required {
                    throw wrongArgCount(signature: signature, got: gotCount)
                }
            } else {
                collected.update(value: last)
            }
        }
        
        // ArgumentList should be empty; if not, user passed too many arguments
        if arguments.head != nil {
            throw wrongArgCount(signature: signature, got: gotCount)
        }
    }
    
    func wrongArgCount(signature: CommandSignature, got: Int) -> CLI.Error {
        var requiredCount = signature.required.count
        if signature.collected?.required == true {
            requiredCount += 1
        }
        let optionalCount = signature.optional.count
        
        let plural = requiredCount == 1 ? "argument" : "arguments"
        if signature.collected != nil {
            return CLI.Error(message: "error: command requires at least \(requiredCount) \(plural), got \(got)")
        }
        if optionalCount == 0 {
            return CLI.Error(message: "error: command requires exactly \(requiredCount) \(plural), got \(got)")
        }
        return CLI.Error(message: "error: command requires between \(requiredCount) and \(requiredCount + optionalCount) arguments, got \(got)")
    }
    
}
