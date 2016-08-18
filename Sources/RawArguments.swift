//
//  RawArguments.swift
//  Example
//
//  Created by Jake Heiser on 1/6/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation

public class RawArguments: CustomStringConvertible {
    
    public enum RawArgumentType {
        case appName
        case commandName
        case option
        case unclassified
    }
    
    private var arguments: [String]
    
    private var argumentClassifications: [RawArgumentType] = []
    
    convenience init() {
        self.init(arguments: ProcessInfo.info.arguments)
    }
    
    convenience init(argumentString: String) {
        let regex = try! Regex(pattern: "(\"[^\"]*\")|[^\"\\s]+", options: [])
        
        let argumentMatches = regex.matches(in: argumentString, options: [], range: NSRange(location: 0, length: argumentString.utf8.count))
        
        let arguments: [String] = argumentMatches.map {(match) in
            let matchRange = match.range
            var argument = argumentString.substring(from: argumentString.characters.index(argumentString.startIndex, offsetBy: matchRange.location))
            argument = argument.substring(to: argument.index(argument.startIndex, offsetBy: matchRange.length))
            if argument.hasPrefix("\"") {
                argument = argument.substring(with: (argument.index(argument.startIndex, offsetBy: 1) ..< argument.index(argument.endIndex, offsetBy: -1)))
            }
            return argument
        }

        self.init(arguments: arguments)
    }
    
    init(arguments: [String]) {
        self.arguments = arguments
        self.argumentClassifications = [RawArgumentType](repeating: .unclassified, count: arguments.count)
        
        classifyArgument(index: 0, type: .appName)
    }
    
    public func classifyArgument(argument: String, type: RawArgumentType) {
        if let index = arguments.index(of: argument) {
            classifyArgument(index: index, type: type)
        }
    }
    
    private func classifyArgument(index: Int, type: RawArgumentType) {
        argumentClassifications[index] = type
    }
    
    func unclassifiedArguments() -> [String] {
        var unclassifiedArguments: [String] = []
        arguments.eachWithIndex {(argument, index) in
            if self.argumentClassifications[index] == .unclassified {
                unclassifiedArguments.append(argument)
            }
        }
        return unclassifiedArguments
    }
    
    public func firstArgumentOfType(_ type: RawArgumentType) -> String? {
        if let index = argumentClassifications.index(of: type) {
            return arguments[index]
        }

        return nil
    }
    
    public func argumentFollowingArgument(_ argument: String) -> String? {
        if let index = arguments.index(of: argument), index + 1 < arguments.count {
            return arguments[index + 1]
        }
        return nil
    }
    
    public var description: String {
        return arguments.description
    }
    
}
