//
//  RawArguments.swift
//  Example
//
//  Created by Jake Heiser on 1/6/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation

public class ArgumentList {
    
    var head: ArgumentNode?
    
    convenience init() {
        self.init(arguments: ProcessInfo.processInfo.arguments)
    }
    
    convenience init(argumentString: String) {
        let regex = try! Regex(pattern: "(\"[^\"]*\")|[^\"\\s]+", options: [])
        
        let argumentMatches = regex.matches(in: argumentString, options: [], range: NSRange(location: 0, length: argumentString.utf8.count))
        
        let arguments: [String] = argumentMatches.map {(match) in
            let matchRange = match.range
            var argument = argumentString.substring(from: argumentString.index(argumentString.startIndex, offsetBy: matchRange.location))
            argument = argument.substring(to: argument.index(argument.startIndex, offsetBy: matchRange.length))
            
            if argument.hasPrefix("\"") {
                argument = argument.substring(with: Range(uncheckedBounds: (lower: argument.index(argument.startIndex, offsetBy: 1), upper: argument.index(argument.endIndex, offsetBy: -1))))
            }
            return argument
        }
        
        self.init(arguments: arguments)
    }
    
    init(arguments stringArguments: [String]) {
        head = CLI.argumentNodeParser.parse(stringArguments: stringArguments)
        
        if let head = head {
            remove(node: head)
        }
    }
    
    func remove(node: ArgumentNode) {
        node.previous?.next = node.next
        node.next?.previous = node.previous
        if node.previous == nil { // Is head
            head = node.next
        }
    }
    
}

public class ArgumentNode {
    
    public let value: String
    
    public var next: ArgumentNode? = nil
    weak public var previous: ArgumentNode? = nil
    
    public init(value: String) {
        self.value = value
    }
    
}
