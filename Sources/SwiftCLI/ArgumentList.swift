//
//  ArgumentList.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//  Copyright (c) 2017 jakeheis. All rights reserved.
//

import Foundation

/// A linked list of the arguments passed by the user
public class ArgumentList {
    
    public var head: ArgumentNode?
    
    /// Creates a list of the arguments passed from the command line
    public convenience init() {
        self.init(arguments: CommandLine.arguments)
    }
    
    /// Creates a list of the arguments from the given string
    public convenience init(argumentString: String) {
        let regex = try! Regex(pattern: "(\"[^\"]*\")|[^\"\\s]+", options: [])
        
        let argumentMatches = regex.matches(in: argumentString, options: [], range: NSRange(location: 0, length: argumentString.utf8.count))
        
        let arguments: [String] = argumentMatches.map {(match) in
            let matchRange = match.range
            let startIndex = argumentString.index(argumentString.startIndex, offsetBy: matchRange.location)
            let endIndex = argumentString.index(argumentString.startIndex, offsetBy: matchRange.location + matchRange.length)
            var argument = String(argumentString[startIndex..<endIndex])
            
            if argument.hasPrefix("\"") {
                argument = String(argument[argument.index(argument.startIndex, offsetBy: 1)..<argument.index(argument.endIndex, offsetBy: -1)])
            }
            return String(argument)
        }
        
        self.init(arguments: arguments)
    }
    
    /// Creates a list of the arguments from given array
    public init(arguments: [String]) {
        var current: ArgumentNode?
        for value in arguments.dropFirst() {
            let argument = ArgumentNode(value: value)
            current?.next = argument
            argument.previous = current
            argument.list = self
            current = argument
            if head == nil {
                head = current
            }
        }
    }
    
    /// Inserts a new argument node with the given value before given node
    ///
    /// - Parameters:
    ///   - value: the value of the new node
    ///   - previous: the node which the new should should be inserted after
    /// - Returns: the newly inserted node
    @discardableResult
    public func insert(value: String, after previous: ArgumentNode) -> ArgumentNode {
        let newNode = ArgumentNode(value: value)
        newNode.previous = previous
        newNode.next = previous.next
        newNode.list = self
        
        previous.next?.previous = newNode
        previous.next = newNode
        return newNode
    }
    
    
    /// Removes the given argument node from the list
    ///
    /// - Parameter node: the node to remove
    public func remove(node: ArgumentNode) {
        node.previous?.next = node.next
        node.next?.previous = node.previous
        if node.previous == nil { // Is head
            head = node.next
        }
    }
    
    /// Creates an iterator of the nodes within the list
    ///
    /// - Returns: a new argument node iterator
    public func iterator() -> ArgumentListIterator {
        return ArgumentListIterator(arguments: self)
    }
    
    /// Counts the number of nodes in the list
    ///
    /// - Returns: the count of nodes
    public func count() -> Int {
        let iter = iterator()
        var count = 0
        while iter.next() != nil {
            count += 1
        }
        return count
    }
    
}

/// A node representing a single argument within the ArgumentList
public class ArgumentNode {
    
    /// The value of this node
    public var value: String
    
    /// The node following this node in the list
    fileprivate(set) public var next: ArgumentNode? = nil
    
    /// The node before this node in the list
    weak fileprivate(set) public var previous: ArgumentNode? = nil
    
    /// The list the node is a part of
    weak fileprivate var list: ArgumentList? = nil
    
    /// Creates a new node with the given value
    ///
    /// - Parameter value: value of the new node
    public init(value: String) {
        self.value = value
    }
    
    public func remove() {
        list?.remove(node: self)
    }
    
}

/// An iterator the argument nodes within an ArgumentList
public class ArgumentListIterator: IteratorProtocol {
    
    private var current: ArgumentNode?
    
    /// Creates a new iterator for the given list
    ///
    /// - Parameter arguments: the arguments list to iterate
    public init(arguments: ArgumentList) {
        current = arguments.head
    }
    
    /// Yields the next sequential node
    ///
    /// - Returns: next sequential node
    public func next() -> ArgumentNode? {
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
