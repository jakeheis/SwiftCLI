//
//  CommandArgumentParser.swift
//  Example
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - CommandArgumentParser

public protocol CommandArgumentParser {
    func parse(rawArguments: RawArguments, with signature: CommandSignature) throws
}

// MARK: - DefaultCommandArgumentParser

public class DefaultCommandArgumentParser: CommandArgumentParser {
    
    public func parse(rawArguments: RawArguments, with signature: CommandSignature) throws {
        for arg in signature.required {
            guard let next = rawArguments.unclassifiedArguments.first else {
                throw CommandArgumentParserError.incorrectUsage("Insufficient number of argument")
            }
            if let argument = arg as? Argument {
                argument.update(value: next.value)
            }
        }
        
        for arg in signature.optional {
            guard let next = rawArguments.unclassifiedArguments.first else {
                break
            }
            if let argument = arg as? OptionalArgument {
                argument.update(value: next.value)
            }
        }
        
        if let collected = signature.collected {
            let last: [String] = rawArguments.unclassifiedArguments.map { $0.value }
            if let argument = collected as? CollectedArgument {
                guard !last.isEmpty else {
                    throw CommandArgumentParserError.incorrectUsage("Insufficient number of argument")
                }
                argument.update(value: last)
            } else if let argument = collected as? OptionalCollectedArgument {
                argument.update(value: last)
            }
        } else if !rawArguments.unclassifiedArguments.isEmpty {
            throw CommandArgumentParserError.incorrectUsage("Too many arguments")
        }
    }
    
}

// MARK: - CommandArgumentParserError

enum CommandArgumentParserError: Error {
    case incorrectUsage(String)
}
