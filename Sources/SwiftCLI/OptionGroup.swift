//
//  OptionGroup.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/31/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

public class OptionGroup {
    
    public enum Restriction {
        case atMostOne // 0 or 1
        case exactlyOne // 1
        case atLeastOne // 1 or more
    }
    
    public let options: [Option]
    public let restriction: Restriction
    
    public var message: String {
        let names = options.optMap({ $0.names.last }).joined(separator: " ")
        
        if options.count == 1 {
            return "Must pass the following option: \(names)"
        }
        
        var str: String
        switch restriction {
        case .exactlyOne:
            str = "Must pass exactly one of the following"
        case .atLeastOne:
            str = "Must pass at least one of the following"
        case .atMostOne:
            str = "Cannot pass more than most one of the following"
        }
        str += ": \(names)"
        return str
    }
    
    public var count: Int = 0
    
    public init(options: [Option], restriction: Restriction) {
        precondition(!options.isEmpty, "must pass one or more options")
        if options.count == 1 {
            precondition(restriction == .exactlyOne, "cannot use atMostOne or atLeastOne when passing one option")
        }
        
        self.options = options
        self.restriction = restriction
    }
    
    public func check() -> Bool  {
        if count == 0 && restriction != .atMostOne {
            return false
        }
        if count > 1 && restriction != .atLeastOne {
            return false
        }
        return true
    }
    
}
