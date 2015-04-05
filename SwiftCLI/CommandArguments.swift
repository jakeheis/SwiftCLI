//
//  CommandArguments.swift
//  Example
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation

public class CommandArguments {
    
    var keyedArguments: [String: AnyObject]
    
    init() {
        self.keyedArguments = [:]
    }
    
    init(keyedArguments: [String: AnyObject]) {
        self.keyedArguments = keyedArguments
    }
    
    init(rawArguments: RawArguments, signature: CommandSignature) {
        self.keyedArguments = [:]
    }
    
    // Keying arguments
    
    class func fromRawArguments(rawArguments: RawArguments, signature: CommandSignature) -> Result<CommandArguments, String> {
        if signature.isEmpty {
            return handleEmptySignature(rawArguments: rawArguments)
        }
        
        let arguments = rawArguments.unclassifiedArguments()
        
        if arguments.count < signature.requiredParameters.count {
            return failure(errorMessage(expectedCount: signature.requiredParameters.count, givenCount: arguments.count))
        }
        
        if signature.terminatedList && signature.optionalParameters.isEmpty && arguments.count != signature.requiredParameters.count {
            return failure(errorMessage(expectedCount: signature.requiredParameters.count, givenCount: arguments.count))
        }
        
        if signature.terminatedList && arguments.count > signature.requiredParameters.count + signature.optionalParameters.count {
            return failure(errorMessage(expectedCount: signature.requiredParameters.count + signature.optionalParameters.count, givenCount: arguments.count))
        }
        
        var commandArguments = CommandArguments()
        
        // First handle required arguments
        for i in 0..<signature.requiredParameters.count {
            let parameter = signature.requiredParameters[i]
            let value = arguments[i]
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
                let value = arguments[index]
                commandArguments[parameter] = value
            }
        }
        
        // Finally group unlimited argument list into last argument if ... is present
        if !signature.terminatedList {
            let parameter = signature.optionalParameters.isEmpty ? signature.requiredParameters[signature.requiredParameters.count-1] : signature.optionalParameters[signature.optionalParameters.count-1]
            var lastArray: [String] = []
            
            lastArray.append(commandArguments.requiredString(parameter))
            
            let startingIndex = signature.requiredParameters.count + signature.optionalParameters.count
            for i in startingIndex..<arguments.count {
                lastArray.append(arguments[i])
            }
            
            commandArguments[parameter] = lastArray
        }
        
        return success(commandArguments)
    }
    
    private class func handleEmptySignature(#rawArguments: RawArguments)-> Result<CommandArguments, String> {
        if rawArguments.unclassifiedArguments().count == 0 {
            return success(CommandArguments())
        } else {
            return failure("Expected no arguments, got \(rawArguments.unclassifiedArguments().count).")
        }
    }
    
    private class func errorMessage(#expectedCount: Int, givenCount: Int) -> String {
        let argString = expectedCount == 1 ? "argument" : "arguments"
        return "Expected \(expectedCount) \(argString), but got \(givenCount)."
    }
    
    // MARK: - Subscripting
    
    public subscript(key: String) -> AnyObject? {
        get {
            return keyedArguments[key]
        }
        set(newArgument) {
            keyedArguments[key] = newArgument
        }
    }
    
    // MARK: - Typesafe shortcuts
    
    public func requiredString(key: String) -> String {
        return optionalString(key)!
    }
    
    public func optionalString(key: String) -> String? {
        if let arg = keyedArguments[key] as? String {
            return arg
        }
        return nil
    }
    
    public func requiredArray(key: String) -> [String] {
        return optionalArray(key)!
    }
    
    public func optionalArray(key: String) -> [String]? {
        if let arg = keyedArguments[key] as? [String] {
            return arg
        }
        return nil
    }
    
}
