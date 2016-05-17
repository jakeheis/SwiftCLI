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
        case AppName
        case CommandName
        case Option
        case Unclassified
    }
    
    private var arguments: [String]
    
    private var argumentClassifications: [RawArgumentType] = []
    
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
    
    init(arguments: [String]) {
        self.arguments = arguments
        self.argumentClassifications = [RawArgumentType](repeating: .Unclassified, count: arguments.count)
        
        classifyArgument(index: 0, type: .AppName)
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
            if self.argumentClassifications[index] == .Unclassified {
                unclassifiedArguments.append(argument)
            }
        }
        return unclassifiedArguments
    }
    
    public func firstArgumentOfType(type: RawArgumentType) -> String? {
        if let index = argumentClassifications.index(of: type) {
            return arguments[index]
        }

        return nil
    }
    
    public func argumentFollowingArgument(argument: String) -> String? {
        if let index = arguments.index(of: argument) where index + 1 < arguments.count {
            return arguments[index + 1]
        }
        return nil
    }
    
    public var description: String {
        return arguments.description
    }
    
}
