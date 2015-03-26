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
    
    public func string(key: String) -> String? {
        if let arg = keyedArguments[key] as? String {
            return arg
        }
        return nil
    }
    
    public func array(key: String) -> [String]? {
        if let arg = keyedArguments[key] as? [String] {
            return arg
        }
        return nil
    }
    
}
