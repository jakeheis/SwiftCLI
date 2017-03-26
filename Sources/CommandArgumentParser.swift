//
//  CommandArgumentParser.swift
//  Example
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - CommandArgumentParser

public protocol CommandArgumentParser {
    func parse(arguments: ArgumentList, for command: Command) throws
}

// MARK: - DefaultCommandArgumentParser

public class DefaultCommandArgumentParser: CommandArgumentParser {
    
    public func parse(arguments: ArgumentList, for command: Command) throws {
        let signature = CommandSignature(command: command)
        
        for argument in signature.required {
            guard let next = arguments.head else {
                throw CommandArgumentParserError.incorrectUsage("Insufficient number of argument")
            }
            argument.update(value: next.value)
            arguments.remove(node: next)
        }
        
        for argument in signature.optional {
            guard let next = arguments.head else {
                break
            }
            argument.update(value: next.value)
            arguments.remove(node: next)
        }
        
        if let collected = signature.collected {
            var last: [String] = []
            while let node = arguments.head {
                last.append(node.value)
                arguments.remove(node: node)
            }
            if last.isEmpty {
                if collected.required {
                    throw CommandArgumentParserError.incorrectUsage("Insufficient number of argument")
                }
            } else {
                collected.update(value: last)
            }
        } else if arguments.head != nil {
            throw CommandArgumentParserError.incorrectUsage("Too many arguments")
        }
    }
    
}

// MARK: - CommandArgumentParserError

enum CommandArgumentParserError: Error {
    case incorrectUsage(String)
}
