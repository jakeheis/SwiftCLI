//
//  CommandArgumentParser.swift
//  Example
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - RawArgumentParser

public protocol ArgumentNodeParser {
    func parse(stringArguments: [String]) -> ArgumentNode?
}

// MARK: - DefaultRawArgumentParser

public class DefaultArgumentNodeParser: ArgumentNodeParser {
    
    public func parse(stringArguments: [String]) -> ArgumentNode? {
        let adjustedArguments = stringArguments.flatMap { (argument) -> [String] in
            if argument.hasPrefix("-") && !argument.hasPrefix("--") {
                return argument.characters.dropFirst().map { "-\($0)" } // Turn -am into -a -m
            }
            return [argument]
        }
        
        var head: ArgumentNode?
        var current: ArgumentNode?
        for value in adjustedArguments {
            let argument = ArgumentNode(value: value)
            current?.next = argument
            argument.previous = current
            current = argument
            if head == nil {
                head = current
            }
        }
        
        return head
    }
    
}
