//
//  CommandArguments.swift
//  Example
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

public class CommandArguments {
    
    let keyedArguments: [String: Any]
    
    init() {
        keyedArguments = [:]
    }
    
    init(rawArguments: RawArguments, signature: CommandSignature) throws {
        keyedArguments = try CLI.commandArgumentParser.parse(rawArguments: rawArguments, with: signature)
    }
    
    // MARK: - Subscripting
    
    /**
        Generic subscripting of arguments
    
        - SeeAlso: Typesafe shortcuts such as `args.requiredArguments("arg")`
    */
    public subscript(key: String) -> Any? {
        get {
            return keyedArguments[key]
        }
    }
    
    // MARK: - Typesafe shortcuts
    
    /**
        Subscripting shortcut for arguments guaranteed to be present. Only use for arguments
        in the command signature of the form `<requiredArgument>`
    
        - Parameter key: the name of the argument as seen in the command signature
    */
    public func requiredArgument(_ key: String) -> String {
        return optionalArgument(key)!
    }
    
    /**
        Subscripting shortcut for arguments sometimes present. Only use for arguments
        in the command signature of the form `[<optionalArgument>]`
    
        - Parameter key: the name of the argument as seen in the command signature
    */
    public func optionalArgument(_ key: String) -> String? {
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
    public func requiredCollectedArgument(_ key: String) -> [String] {
        return optionalCollectedArgument(key)!
    }
    
    /**
        Subscripting shortcut for a collected argument sometimes present. Only use
        for arguments in the command signature of the form `[<optionalArgument>] ...`
    
        - Parameter key: the name of the argument as seen in the command signature
    */
    public func optionalCollectedArgument(_ key: String) -> [String]? {
        if let arg = keyedArguments[key] as? [String] {
            return arg
        }
        return nil
    }
    
}
