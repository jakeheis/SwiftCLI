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
    
    /// Creates a list of the arguments from given array
    public init(arguments: [String]) {
        self.storage = arguments
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
    @discardableResult
    public func pop() -> String {
        return storage.removeFirst()
    }
    
    /// Peeks at the next argument
    ///
    /// - Returns: the next argument
    /// - Precondition: list must not be empty
    @discardableResult
    public func peek() -> String {
        return storage[0]
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
