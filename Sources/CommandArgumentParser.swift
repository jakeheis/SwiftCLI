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
        for argument in signature.required {
            guard let next = rawArguments.unclassifiedArguments.first else {
                throw CommandArgumentParserError.incorrectUsage("Insufficient number of argument")
            }
            argument.update(value: next.value)
            next.classification = .commandArgument
        }
        
        for argument in signature.optional {
            guard let next = rawArguments.unclassifiedArguments.first else {
                break
            }
            argument.update(value: next.value)
            next.classification = .commandArgument
        }
        
        if let collected = signature.collected {
            let last: [String] = rawArguments.unclassifiedArguments.map { $0.value }
            if collected.required && last.isEmpty {
                throw CommandArgumentParserError.incorrectUsage("Insufficient number of argument")
            }
            collected.update(value: last)
        } else if !rawArguments.unclassifiedArguments.isEmpty {
            print(rawArguments.unclassifiedArguments.map { $0.value })
            throw CommandArgumentParserError.incorrectUsage("Too many arguments")
        }
    }
    
}

// MARK: - CommandArgumentParserError

enum CommandArgumentParserError: Error {
    case incorrectUsage(String)
}
