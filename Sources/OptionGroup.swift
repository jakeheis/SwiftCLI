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
        let names = options.flatMap({ $0.names.first }).joined(separator: " ")
        var str = "Must pass "
        switch restriction {
        case .exactlyOne:
            str += "exactly one of"
        case .atLeastOne:
            str += "at least one of"
        case .atMostOne:
            str += "at most one of"
        }
        str += ": \(names)"
        return str
    }
    
    public var count: Int = 0
    
    public init(options: [Option], restriction: Restriction) {
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
