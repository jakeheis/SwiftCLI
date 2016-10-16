//
//  CommandArgumentParser.swift
//  Example
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - CommandArgumentParser

public protocol CommandArgumentParser {
    func parse(rawArguments: RawArguments, with signature: CommandSignature) throws -> [String: Any]
}

// MARK: - DefaultCommandArgumentParser

public class DefaultCommandArgumentParser: CommandArgumentParser {
    
    public func parse(rawArguments: RawArguments, with signature: CommandSignature) throws -> [String: Any] {
        if signature.isEmpty {
            guard rawArguments.unclassifiedArguments.isEmpty else {
                throw CommandArgumentParserError.incorrectUsage("Expected no arguments, got \(rawArguments.unclassifiedArguments.count).")
            }
            return [:]
        }
        
        let arguments = rawArguments.unclassifiedArguments
        
        // Not enough arguments
        if arguments.count < signature.requiredParameters.count {
            throw CommandArgumentParserError.incorrectUsage(errorMessage(expectedCount: signature.requiredParameters.count, givenCount: arguments.count))
        }
        
        // Too many arguments
        if !signature.collectRemainingArguments && arguments.count > signature.requiredParameters.count + signature.optionalParameters.count {
            throw CommandArgumentParserError.incorrectUsage(errorMessage(expectedCount: signature.requiredParameters.count + signature.optionalParameters.count, givenCount: arguments.count))
        }
        
        var commandArguments: [String: Any] = [:]
        
        // First handle required arguments
        for i in 0..<signature.requiredParameters.count {
            let parameter = signature.requiredParameters[i]
            let value = arguments[i].value
            commandArguments[parameter] = value
        }
        
        // Then handle optional arguments if there are any
        if !signature.optionalParameters.isEmpty && arguments.count > signature.requiredParameters.count {
            for i in 0..<signature.optionalParameters.count {
                let index = i + signature.requiredParameters.count
                if index >= arguments.count {
                    break
                }
                let parameter = signature.optionalParameters[i]
                let value = arguments[index].value
                commandArguments[parameter] = value
            }
        }
        
        // Finally collect the remaining arguments into an array if ... is present
        if signature.collectRemainingArguments {
            let parameter = signature.optionalParameters.isEmpty ? signature.requiredParameters[signature.requiredParameters.count-1] : signature.optionalParameters[signature.optionalParameters.count-1]

            if let singleArgument = commandArguments[parameter] as? String {
                var collectedArgument = [singleArgument]
                let startingIndex = signature.requiredParameters.count + signature.optionalParameters.count
                for i in startingIndex..<arguments.count {
                    collectedArgument.append(arguments[i].value)
                }
                commandArguments[parameter] = collectedArgument
            }
        }
        
        return commandArguments
    }
    
    private func errorMessage(expectedCount: Int, givenCount: Int) -> String {
        let argString = expectedCount == 1 ? "argument" : "arguments"
        return "Expected \(expectedCount) \(argString), but got \(givenCount)."
    }
    
}

// MARK: - CommandArgumentParserError

enum CommandArgumentParserError: Error {
    case incorrectUsage(String)
}
