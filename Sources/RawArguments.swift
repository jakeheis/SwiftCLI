//
//  RawArguments.swift
//  Example
//
//  Created by Jake Heiser on 1/6/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation

public class RawArgument {
    
    public enum Classification {
        case appName
        case commandName
        case option
        case unclassified
    }
    
    public let value: String
    public let index: Int
    
    public var next: RawArgument? = nil
    public var classification: Classification = .unclassified
    
    public var isUnclassified: Bool {
        return classification == .unclassified
    }
    
    public init(value: String, index: Int) {
        self.value = value
        self.index = index
    }
    
}

public class RawArguments {
    
    internal var arguments: [RawArgument]
    
    internal var originalString: String
    
    public var unclassifiedArguments: [RawArgument] {
        return arguments.filter { $0.isUnclassified }
    }
    
    convenience init() {
        self.init(arguments: ProcessInfo.processInfo.arguments, with:ProcessInfo.processInfo.arguments.joined(separator:" "))
    }
    
    convenience init(argumentString: String) {
        let regex = try! Regex(pattern: "(\"[^\"]*\")|[^\"\\s]+", options: [])
        
        let argumentMatches = regex.matches(in: argumentString, options: [], range: NSRange(location: 0, length: argumentString.utf8.count))
        
        var arguments: [String] = argumentMatches.map {(match) in
            let matchRange = match.range
            var argument = argumentString.substring(from: argumentString.index(argumentString.startIndex, offsetBy: matchRange.location))
            argument = argument.substring(to: argument.index(argument.startIndex, offsetBy: matchRange.length))

            if argument.hasPrefix("\"") {
                argument = argument.substring(with: Range(uncheckedBounds: (lower: argument.index(argument.startIndex, offsetBy: 1), upper: argument.index(argument.endIndex, offsetBy: -1))))
            }
            return argument
        }

        self.init(arguments: arguments, with: argumentString)
    }
    
    init(arguments stringArguments: [String], with originalString: String) {
        self.originalString = originalString
        arguments = CLI.rawArgumentParser.parse(stringArguments: stringArguments)
        arguments.first?.classification = .appName
    }
    
}
