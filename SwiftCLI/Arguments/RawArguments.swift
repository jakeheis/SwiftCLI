//
//  RawArguments.swift
//  Example
//
//  Created by Jake Heiser on 1/6/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation

class RawArguments {
    
    enum RawArgumentType {
        case AppName
        case CommandName
        case Option
        case Unclassified
    }
    
    private var arguments: [String]
    
    private var argumentClassifications: [RawArgumentType] = []
    
    convenience init() {
        let arguments = NSProcessInfo.processInfo().arguments as! [String]
        
        self.init(arguments: arguments)
    }
    
    convenience init(argumentString: String) {
        let arguments = argumentString.componentsSeparatedByString(" ").filter { !$0.isEmpty }

        self.init(arguments: arguments)
    }
    
    init(arguments: [String]) {
        self.arguments = arguments
        self.argumentClassifications = [RawArgumentType](count: arguments.count, repeatedValue: .Unclassified)
        
        classifyArgument(index: 0, type: .AppName)
    }
    
    func classifyArgument(#argument: String, type: RawArgumentType) {
        if let index = find(arguments, argument) {
            classifyArgument(index: index, type: type)
        }
    }
    
    private func classifyArgument(#index: Int, type: RawArgumentType) {
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
    
    func firstArgumentOfType(type: RawArgumentType) -> String? {
        if let index = find(argumentClassifications, type) {
            return arguments[index]
        }

        return nil
    }
    
    func argumentFollowingArgument(argument: String) -> String? {
        if let index = find(arguments, argument) where index + 1 < arguments.count {
            return arguments[index + 1]
        }
        return nil
    }
    
}