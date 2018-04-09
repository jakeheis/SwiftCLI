//
//  ArgumentList.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//  Copyright (c) 2017 jakeheis. All rights reserved.
//

import Foundation

public class ArgumentList {
    
    private var storage: [String]
    
    /// Creates a list of the arguments passed from the command line
    public convenience init() {
        self.init(arguments: CommandLine.arguments)
    }

    /// Creates a list of the arguments from the given string; parses similar to how shell parses arguments
    ///
    /// - Parameter argumentString: string from which to parse argument
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
        self.storage = Array(arguments.dropFirst())
    }
    
    /// Checks if list has another argument
    ///
    /// - Returns: whether list has another argument
    public func hasNext() -> Bool {
        return !storage.isEmpty
    }
    
    /// Pops off the next argument
    ///
    /// - Returns: the next argument
    /// - Precondition: list must not be empty
    public func pop() -> String {
        return storage.removeFirst()
    }
    
    /// Checks if the next argument is an option argument
    ///
    /// - Returns: whether next argument is an option
    public func nextIsOption() -> Bool {
        return storage.first?.hasPrefix("-") ?? false
    }
    
    /// Manipulate the argument list with the given closure
    ///
    /// - Parameter manipiulation: closure which takes in current array of arguments, returns manipulated array of args
    public func manipulate(_ manipiulation: ([String]) -> [String]) {
        storage = manipiulation(storage)
    }
    
}

extension ArgumentList: CustomStringConvertible {
    public var description: String {
        return storage.description
    }
}
