//
//  OptionGroup.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/31/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

public class OptionGroup: CustomStringConvertible {
    
    public enum Restriction {
        case atMostOne // 0 or 1
        case exactlyOne // 1
        case atLeastOne // 1 or more
    }
    
    public static func atMostOne(_ options: Option...) -> OptionGroup {
        return .atMostOne(options)
    }
    
    public static func atMostOne(_ options: [Option]) -> OptionGroup {
        return .init(options: options, restriction: .atMostOne)
    }
    
    public static func exactlyOne(_ options: Option...) -> OptionGroup {
        return .exactlyOne(options)
    }
    
    public static func exactlyOne(_ options: [Option]) -> OptionGroup {
        return .init(options: options, restriction: .exactlyOne)
    }
    
    public static func atLeastOne(_ options: Option...) -> OptionGroup {
        return .atLeastOne(options)
    }
    
    public static func atLeastOne(_ options: [Option]) -> OptionGroup {
        return .init(options: options, restriction: .atLeastOne)
    }
    
    public let options: [Option]
    public let restriction: Restriction
    internal(set) public var count: Int = 0
    
    public var description: String {
        return "OptionGroup.\(restriction)(\(options))"
    }
    
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
