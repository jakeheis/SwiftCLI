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
        self.init(arguments: CommandLine.arguments)
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
    
    init(arguments: [String]) {
        var current: ArgumentNode?
        for value in arguments.dropFirst() {
            let argument = ArgumentNode(value: value)
            current?.next = argument
            argument.previous = current
            current = argument
            if head == nil {
                head = current
            }
        }
    }
    
    func insert(node: String, after previous: ArgumentNode) -> ArgumentNode {
        let newNode = ArgumentNode(value: node)
        newNode.previous = previous
        newNode.next = previous.next
        
        previous.next?.previous = newNode
        previous.next = newNode
        return newNode
    }
    
    func remove(node: ArgumentNode) {
        node.previous?.next = node.next
        node.next?.previous = node.previous
        if node.previous == nil { // Is head
            head = node.next
        }
    }
    
    func iterator() -> ArgumentListIterator {
        return ArgumentListIterator(arguments: self)
    }
    
}

public class ArgumentNode {
    
    public var value: String
    
    public var next: ArgumentNode? = nil
    weak public var previous: ArgumentNode? = nil
    
    public init(value: String) {
        self.value = value
    }
    
}

class ArgumentListIterator: IteratorProtocol {
    
    var current: ArgumentNode?
    
    init(arguments: ArgumentList) {
        current = arguments.head
    }
    
    func next() -> ArgumentNode? {
        let this = current
        current = current?.next
        return this
    }
    
}

// MARK: - Regex

#if os(Linux)
#if swift(>=3.1)
    typealias Regex = NSRegularExpression
#else
    typealias Regex = RegularExpression
#endif
#else
    typealias Regex = NSRegularExpression
    
#endif
