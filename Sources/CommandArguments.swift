//
//  CommandArguments.swift
//  Example
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

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
    
    class func fromRawArguments(rawArguments: RawArguments, signature: CommandSignature) throws -> CommandArguments {
        if signature.isEmpty {
            return try handleEmptySignature(rawArguments: rawArguments)
        }
        
        let arguments = rawArguments.unclassifiedArguments()
        
        if arguments.count < signature.requiredParameters.count {
            throw CLIError.Error(errorMessage(expectedCount: signature.requiredParameters.count, givenCount: arguments.count))
        }
        
        if !signature.collectRemainingArguments && signature.optionalParameters.isEmpty && arguments.count != signature.requiredParameters.count {
            throw CLIError.Error(errorMessage(expectedCount: signature.requiredParameters.count, givenCount: arguments.count))
        }
        
        if !signature.collectRemainingArguments && arguments.count > signature.requiredParameters.count + signature.optionalParameters.count {
            throw CLIError.Error(errorMessage(expectedCount: signature.requiredParameters.count + signature.optionalParameters.count, givenCount: arguments.count))
        }
        
        let commandArguments = CommandArguments()
        
        // First handle required arguments
        for i in 0..<signature.requiredParameters.count {
            let parameter = signature.requiredParameters[i]
            let value = arguments[i]
            commandArguments[parameter] = value as AnyObject
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
                commandArguments[parameter] = value as AnyObject
            }
        }
        
        // Finally collect the remaining arguments into an array if ... is present
        if signature.collectRemainingArguments {
            let parameter = signature.optionalParameters.isEmpty ? signature.requiredParameters[signature.requiredParameters.count-1] : signature.optionalParameters[signature.optionalParameters.count-1]

            if let singleArgument = commandArguments.optionalArgument(key: parameter) {
                var collectedArgument = [singleArgument]
                let startingIndex = signature.requiredParameters.count + signature.optionalParameters.count
                for i in startingIndex..<arguments.count {
                    collectedArgument.append(arguments[i])
                }
                commandArguments[parameter] = collectedArgument as AnyObject
            }
        }
        
        return commandArguments
    }
    
    private class func handleEmptySignature(rawArguments: RawArguments) throws -> CommandArguments {
        guard rawArguments.unclassifiedArguments().count == 0  else {
            throw CLIError.Error("Expected no arguments, got \(rawArguments.unclassifiedArguments().count).")
        }
    
        return CommandArguments()
    }
    
    private class func errorMessage(expectedCount: Int, givenCount: Int) -> String {
        let argString = expectedCount == 1 ? "argument" : "arguments"
        return "Expected \(expectedCount) \(argString), but got \(givenCount)."
    }
    
    // MARK: - Subscripting
    
    /**
        Generic subscripting of arguments
    
        - SeeAlso: Typesafe shortcuts such as `args.requiredArguments("arg")`
    */
    public subscript(key: String) -> AnyObject? {
        get {
            return keyedArguments[key]
        }
        set(newArgument) {
            keyedArguments[key] = newArgument
        }
    }
    
    // MARK: - Typesafe shortcuts
    
    /**
        Subscripting shortcut for arguments guaranteed to be present. Only use for arguments
        in the command signature of the form `<requiredArgument>`
    
        - Parameter key: the name of the argument as seen in the command signature
    */
    public func requiredArgument(key: String) -> String {
        return optionalArgument(key: key)!
    }
    
    /**
        Subscripting shortcut for arguments sometimes present. Only use for arguments
        in the command signature of the form `[<optionalArgument>]`
    
        - Parameter key: the name of the argument as seen in the command signature
    */
    public func optionalArgument(key: String) -> String? {
        if let arg = keyedArguments[key] as? String {
            return arg
        }
        return nil
    }
    
    /**
        Subscripting shortcut for a collected argument guaranteed to be present. Only use
        for arguments in the command signature of the form `<requiredArgument> ...`
    
        - Parameter key: the name of the argument as seen in the command signature
    */
    public func requiredCollectedArgument(key: String) -> [String] {
        return optionalCollectedArgument(key: key)!
    }
    
    /**
        Subscripting shortcut for a collected argument sometimes present. Only use
        for arguments in the command signature of the form `[<optionalArgument>] ...`
    
        - Parameter key: the name of the argument as seen in the command signature
    */
    public func optionalCollectedArgument(key: String) -> [String]? {
        if let arg = keyedArguments[key] as? [String] {
            return arg
        }
        return nil
    }
    
}
