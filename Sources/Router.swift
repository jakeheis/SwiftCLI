//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol Router {
    mutating func route(commands: [Command], aliases: [String: String], arguments: inout RawArguments) -> Command?
}

// MARK: - DefaultRouter

public class DefaultRouter: Router {
    
    public let fallbackCommand: Command?
    
    public init(fallbackCommand: Command? = nil) {
        self.fallbackCommand = fallbackCommand
    }
    
    public func route(commands: [Command], aliases: [String: String], arguments: inout RawArguments) -> Command? {
        guard var commandNameArgument = arguments.unclassifiedArguments.first else {
            return fallbackCommand
        }
        
        let matchingName = (aliases[commandNameArgument.value] ?? commandNameArgument.value).components(separatedBy: " ")
        
        if (matchingName.count > 1) {
            
            var tempArray = arguments.originalString.components(separatedBy: " ")
            
            let itemToRemove = commandNameArgument.value
            
            while tempArray.contains(itemToRemove) {
                
                if let itemToRemoveIndex = tempArray.index(of: itemToRemove) {
                    tempArray.remove(at: itemToRemoveIndex)
                    var newValues: [String] = []
                    for component in matchingName {
                        
                        newValues.append(component)
                        
                    }
                    tempArray.insert(contentsOf: newValues, at: itemToRemoveIndex)
                }
                arguments = RawArguments(argumentString: tempArray.joined(separator: " "))
                
            }
            
        }
        
        if let command = commands.first(where: { $0.name == matchingName[0] }) {
            guard var revisedCommandNameArgument = arguments.unclassifiedArguments.first else {
                return fallbackCommand
            }
            revisedCommandNameArgument.classification = .commandName
            return command
        }
        
        return fallbackCommand
    }
    
}
