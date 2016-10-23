//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol Router {
    func route(commands: [Command], aliases: [String: String], arguments: RawArguments) -> Command?
}

// MARK: - DefaultRouter

public class DefaultRouter: Router {
    
    public let fallbackCommand: Command?
    
    public init(fallbackCommand: Command? = nil) {
        self.fallbackCommand = fallbackCommand
    }
    
    public func route(commands: [Command], aliases: [String: String], arguments: RawArguments) -> Command? {
        guard let commandNameArgument = arguments.unclassifiedArguments.first else {
            return fallbackCommand
        }
        
        let matchingName = aliases[commandNameArgument.value] ?? commandNameArgument.value
        if let command = commands.first(where: { $0.name == matchingName }) {
            commandNameArgument.classification = .commandName
            return command
        }
        
        return fallbackCommand
    }
    
}
