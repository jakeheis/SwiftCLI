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
        
        // First satisfy required parameters
        for parameter in signature.required {
            guard let next = arguments.head else {
                throw ParameterFillerError.tooFewArguments
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
                    throw ParameterFillerError.tooFewArguments
                }
            } else {
                collected.update(value: last)
            }
        }
        
        // ArgumentList should be empty; if not, user passed too many arguments
        if arguments.head != nil {
            throw ParameterFillerError.tooManyArguments
        }
    }
    
}

// MARK: - ParameterFillerError

public enum ParameterFillerError: Error {
    case tooFewArguments
    case tooManyArguments
    
    public var message: String {
        switch self {
        case .tooFewArguments: return "Insufficient number of argument"
        case .tooManyArguments: return "Too many arguments"
        }
    }
}
