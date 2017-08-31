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
    func fillParameters(of command: Command, with arguments: ArgumentList) throws
}

// MARK: - DefaultParameterFiller

public class DefaultParameterFiller: ParameterFiller {
    
    public func fillParameters(of command: Command, with arguments: ArgumentList) throws {
        let signature = CommandSignature(command: command)
        let requiredCount = signature.requiredCount()
        let gotCount = arguments.count()
        
        // First satisfy required parameters
        for parameter in signature.required {
            guard let next = arguments.head else {
                throw wrongArgCount(expected: requiredCount, got: gotCount)
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
                    throw wrongArgCount(expected: requiredCount, got: gotCount)
                }
            } else {
                collected.update(value: last)
            }
        }
        
        // ArgumentList should be empty; if not, user passed too many arguments
        if arguments.head != nil {
            throw wrongArgCount(expected: requiredCount, got: gotCount)
        }
    }
    
    func wrongArgCount(expected: Int, got: Int) -> Error {
        let arguments = expected == 1 ? "argument" : "arguments"
        return CLI.Error(message: "command expected \(expected) \(arguments), got \(got)")
    }
    
}
