//
//  SignatureParser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class SignatureParser {
    
    let signature: String
    let arguments: [String]
    
    init(signature: String, arguments: [String]) {
        self.signature = signature
        self.arguments = arguments
    }
    
    func parse() -> (keyedArguments: NSDictionary?, errorMessage: String?) {
        if self.signature == "" {
            return self.handleEmptySignature()
        }
        
        let (requiredArgs, optionalArgs, terminatedList) = self.parseSignature(self.signature)
        
        if self.arguments.count < requiredArgs.count {
            return (nil, self.errorMessage(expectedCount: requiredArgs.count, givenCount: self.arguments.count))
        }
        
        if optionalArgs.isEmpty && terminatedList && arguments.count != requiredArgs.count {
            return (nil, self.errorMessage(expectedCount: requiredArgs.count, givenCount: self.arguments.count))
        }
        
        if terminatedList && self.arguments.count > requiredArgs.count + optionalArgs.count {
            return (nil, self.errorMessage(expectedCount: requiredArgs.count + optionalArgs.count, givenCount: self.arguments.count))
        }

        var namedArgs: NSMutableDictionary = [:]
        
        // First handle required arguments
        for i in 0..<requiredArgs.count {
            let name = self.sanitizeKey(requiredArgs[i])
            let value = self.arguments[i]
            namedArgs[name] = value
        }
        
        // Then handle optional arguments if there are any
        if !optionalArgs.isEmpty && self.arguments.count > requiredArgs.count {
            for i in 0..<optionalArgs.count {
                let index = i + requiredArgs.count
                if index >= self.arguments.count {
                    break
                }
                let name = self.sanitizeKey(optionalArgs[i])
                let value = self.arguments[index]
                namedArgs[name] = value
            }
        }
        
        // Finally group unlimited argument list into last argument if ... is present
        if !terminatedList {
            let lastKey = optionalArgs.isEmpty ? requiredArgs[requiredArgs.count-1] : optionalArgs[optionalArgs.count-1]
            let name = self.sanitizeKey(lastKey)
            var lastArray: [String] = []
            
            lastArray.append(namedArgs[name] as String)
            
            let startingIndex = requiredArgs.count + optionalArgs.count
            for i in startingIndex..<self.arguments.count {
                lastArray.append(self.arguments[i])
            }
            
            namedArgs[name] = lastArray
        }
        
        return (namedArgs, nil)
    }
    
    // MARK: - Privates
    
    private func handleEmptySignature()-> (NSDictionary?, String?) {
        if self.arguments.count == 0 {
            return (NSDictionary(), nil)
        } else {
            return (nil, "Expected no arguments, got \(self.arguments.count).")
        }
    }
    
    private func parseSignature(signature: String) -> (requiredArgs: [String], optionalArgs: [String], terminatedList: Bool) {
        var expectedArguments = signature.componentsSeparatedByString(" ")

        var requiredArgs: [String] = []
        var optionalArgs: [String] = []
        var terminatedList = true
        
        for argument in expectedArguments {
            if argument == "..." {
                let lastObject = expectedArguments[expectedArguments.count-1]
                assert(argument == lastObject, "The non-terminal parameter must be at the end of a command signature.")
                terminatedList = false
                continue
            }
            
            if argument.hasPrefix("[") {
                optionalArgs.append(argument)
            } else {
                assert(optionalArgs.isEmpty, "All optional arguments must come after required arguments in a command signature")
                requiredArgs.append(argument)
            }
        }
        
        return (requiredArgs, optionalArgs, terminatedList)
    }
    
    private func sanitizeKey(key: String) -> String {
        let arg = key as NSString
        let multiplier = key.hasPrefix("[") ? 2 : 1
        return arg.substringWithRange(NSMakeRange(1 * multiplier, key.utf16Count - 2 * multiplier))
    }
    
    private func errorMessage(#expectedCount: Int, givenCount: Int) -> String {
        let argString = expectedCount == 1 ? "argument" : "arguments"
        return "Expected \(expectedCount) \(argString), but got \(givenCount)."
    }
}