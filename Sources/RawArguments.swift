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
    
    let value: String
    let index: Int
    
    var next: RawArgument? = nil
    var classification: Classification = .unclassified
    
    var isUnclassified: Bool {
        return classification == .unclassified
    }
    
    init(value: String, index: Int) {
        self.value = value
        self.index = index
    }
    
}

public class RawArguments {
    
    private let arguments: [RawArgument]
    
    var unclassifiedArguments: [RawArgument] {
        return arguments.filter { $0.isUnclassified }
    }
    
    convenience init() {
        self.init(arguments: NSProcessInfo.processInfo().arguments)
    }
    
    convenience init(argumentString: String) {
        let regex = try! NSRegularExpression(pattern: "(\"[^\"]*\")|[^\"\\s]+", options: [])
        
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
        arguments = CLI.rawArgumentParser.parse(stringArguments: stringArguments)
        
        arguments.first?.classification = .appName
    }
    
}
