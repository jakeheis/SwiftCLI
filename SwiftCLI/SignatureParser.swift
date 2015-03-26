//
//  SignatureParser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation
//import LlamaKit

class SignatureParser {
    
    private let signature: CommandSignature
    private let arguments: [String]
    
    init(signature: CommandSignature, rawArguments: RawArguments) {
        self.signature = signature
        self.arguments = rawArguments.nonoptionsArguments()
    }
    
    func parse() -> Result<CommandArguments, String> {
        if signature.isEmpty {
            return handleEmptySignature()
        }
        
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
            
            lastArray.append(commandArguments.string(parameter)!)
            
            let startingIndex = signature.requiredParameters.count + signature.optionalParameters.count
            for i in startingIndex..<arguments.count {
                lastArray.append(arguments[i])
            }
            
            commandArguments[parameter] = lastArray
        }
        
        return success(commandArguments)
    }
    
    // MARK: - Privates
    
    private func handleEmptySignature()-> Result<CommandArguments, String> {
        if arguments.count == 0 {
            return success(CommandArguments())
        } else {
            return failure("Expected no arguments, got \(arguments.count).")
        }
    }
    
    private func errorMessage(#expectedCount: Int, givenCount: Int) -> String {
        let argString = expectedCount == 1 ? "argument" : "arguments"
        return "Expected \(expectedCount) \(argString), but got \(givenCount)."
    }
    
}