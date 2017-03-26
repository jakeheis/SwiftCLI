//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol Router {
    func route(commands: [Command], aliases: [String: String], arguments: ArgumentList) -> Command?
}

// MARK: - DefaultRouter

public class DefaultRouter: Router {
    
    public let fallbackCommand: Command?
    
    public init(fallbackCommand: Command? = nil) {
        self.fallbackCommand = fallbackCommand
    }
    
    public func route(commands: [Command], aliases: [String: String], arguments: ArgumentList) -> Command? {
        guard let commandNameArgument = arguments.head else {
            return fallbackCommand
        }
        
        let matchingName = aliases[commandNameArgument.value] ?? commandNameArgument.value
        if let command = commands.first(where: { $0.name == matchingName }) {
            arguments.remove(node: commandNameArgument)
            return command
        }
        
        return fallbackCommand
    }
    
}
