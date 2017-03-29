//
//  CommandArgumentParser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - CommandArgumentParser

/// Protcol representing an object which parses the arguments for a command from an argument list
public protocol CommandArgumentParser {
    func parse(arguments: ArgumentList, for command: Command) throws
}

// MARK: - DefaultCommandArgumentParser

public class DefaultCommandArgumentParser: CommandArgumentParser {
    
    public func parse(arguments: ArgumentList, for command: Command) throws {
        let signature = CommandSignature(command: command)
        
        // First satisfy required parameters
        for argument in signature.required {
            guard let next = arguments.head else {
                throw CommandArgumentParserError.tooFewArguments
            }
            argument.update(value: next.value)
            arguments.remove(node: next)
        }
        
        // Then optional parameters
        for argument in signature.optional {
            guard let next = arguments.head else {
                break
            }
            argument.update(value: next.value)
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
                    throw CommandArgumentParserError.tooFewArguments
                }
            } else {
                collected.update(value: last)
            }
        }
        
        // ArgumentList should be empty; if not, user passed too many arguments
        if arguments.head != nil {
            throw CommandArgumentParserError.tooManyArguments
        }
    }
    
}

// MARK: - CommandArgumentParserError

enum CommandArgumentParserError: Error {
    case tooFewArguments
    case tooManyArguments
    
    var message: String {
        switch self {
        case .tooFewArguments: return "Insufficient number of argument"
        case .tooManyArguments: return "Too many arguments"
        }
    }
}
