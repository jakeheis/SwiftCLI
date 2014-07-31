//
//  SignatureParser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class SignatureParser {
    
    class func parse(signature: String, arguments: [String]) -> (NSDictionary?, String?) {
        if signature == "" {
            if arguments.count == 0 {
                return (NSDictionary.dictionary(), nil)
            } else {
                return (nil, "Expected no arguments, got \(arguments.count).")
            }
        }
        
        var expectedArguments = signature.componentsSeparatedByString(" ")
        
        if expectedArguments[expectedArguments.count-1] == "..." {
            expectedArguments.removeLast()
        } else if arguments.count > expectedArguments.count {
            return (nil, self.errorMessage(expectedCount: expectedArguments.count, givenCount: arguments.count))
        }

        if arguments.count < expectedArguments.count {
            return (nil, self.errorMessage(expectedCount: expectedArguments.count, givenCount: arguments.count))
        }

        var namedArgs: NSMutableDictionary = [:]
        
        for i in 0..<expectedArguments.count {
            let name = self.sanitizeKey(expectedArguments[i])
            
            let value = arguments[i]
            
            namedArgs[name] = value
        }
        
        if arguments.count > expectedArguments.count {
            let name = self.sanitizeKey(expectedArguments[expectedArguments.count-1])
            var lastArray: [String] = []
            
            lastArray.append(namedArgs[name] as String)
            
            for i in expectedArguments.count..<arguments.count {
                lastArray.append(arguments[i])
            }
            
            namedArgs[name] = lastArray
        }
                
        return (namedArgs, nil)
    }
    
    class func sanitizeKey(key: String) -> String {
        let  arg = key as NSString
        return arg.substringWithRange(NSMakeRange(1, key.utf16Count - 2))
    }
    
    class func errorMessage(#expectedCount: Int, givenCount: Int) -> String {
        let argString = expectedCount == 1 ? "argument" : "arguments"
        return "Expected \(expectedCount) \(argString), but got \(givenCount)."
    }
}