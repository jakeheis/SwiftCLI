//
//  CommandArguments.swift
//  Example
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation

class CommandArguments {
    
    var keyedArguments: NSDictionary
    
    init(keyedArguments: NSDictionary) {
        self.keyedArguments = keyedArguments
    }
    
    subscript(key: String) -> AnyObject? {
        return keyedArguments[key]
    }
    
    // MARK: - Typesafe shortcuts
    
    func string(key: String) -> String? {
        if let arg = keyedArguments[key] as? String {
            return arg
        }
        return nil
    }
    
    func array(key: String) -> [String]? {
        if let arg = keyedArguments[key] as? [String] {
            return arg
        }
        return nil
    }
    
}
