//
//  CommandArgumentParser.swift
//  Example
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - RawArgumentParser

public protocol RawArgumentParser {
    func parse(stringArguments: [String]) -> [RawArgument]
}

// MARK: - DefaultRawArgumentParser

public class DefaultRawArgumentParser: RawArgumentParser {
    
    public func parse(stringArguments: [String]) -> [RawArgument] {
        let adjustedArguments = stringArguments.flatMap { (argument) -> [String] in
            if argument.hasPrefix("-") && !argument.hasPrefix("--") {
                return argument.characters.dropFirst().map { "-\($0)" } // Turn -am into -a -m
            }
            return [argument]
        }
        
        var convertedArguments: [RawArgument] = []
        var lastArgument: RawArgument? = nil
        for (index, value) in adjustedArguments.enumerated() {
            let argument = RawArgument(value: value, index: index)
            convertedArguments.append(argument)
            if let lastArgument = lastArgument {
                lastArgument.next = argument
            }
            lastArgument = argument
        }
        
        return convertedArguments
    }
    
}
