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
    
    func parse() -> (NSDictionary?, String?) {
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

        var namedArgs: NSMutableDictionary = [:]
        
        for i in 0..<requiredArgs.count {
            let name = self.sanitizeKey(requiredArgs[i])
            let value = self.arguments[i]
            namedArgs[name] = value
        }
        
        if arguments.count > requiredArgs.count {
            if !terminatedList {
                let name = self.sanitizeKey(requiredArgs.lastObject()!)
                var lastArray: [String] = []
                
                lastArray.append(namedArgs[name] as String)
                
                for i in requiredArgs.count..<self.arguments.count {
                    lastArray.append(self.arguments[i])
                }
                
                namedArgs[name] = lastArray
            } else {
                for i in 0..<optionalArgs.count {
                    let name = self.sanitizeKey(optionalArgs[i])
                    let value = self.arguments[i + requiredArgs.count]
                    namedArgs[name] = value
                }
            }
        }
        
        return (namedArgs, nil)
    }
    
    private func handleEmptySignature()-> (NSDictionary?, String?) {
        if self.arguments.count == 0 {
            return (NSDictionary.dictionary(), nil)
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
                assert(argument == expectedArguments.lastObject()!, "The non-terminal parameter must be at the end of a command signature.")
                assert(optionalArgs.isEmpty, "There can not be optional arguments and a non-terminal parametrs in a command signature.")
                terminatedList = false
                continue
            }
            
            if argument.hasPrefix("[") {
                optionalArgs += argument
            } else {
                assert(optionalArgs.isEmpty, "All optional arguments must come after required arguments in a command signature")
                requiredArgs += argument
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

extension Array {
    
    func lastObject() -> T? {
        return self.count > 0 ? self[self.count-1] : nil;
    }
    
}