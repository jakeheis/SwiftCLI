//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol Router {
    func route(commands: [Command], arguments: RawArguments) -> Command?
}

// MARK: - DefaultRouter

public class DefaultRouter: Router {
    
    let fallbackCommand: Command?
    
    init(fallbackCommand: Command? = nil) {
        self.fallbackCommand = fallbackCommand
    }
    
    public func route(commands: [Command], arguments: RawArguments) -> Command? {
        guard let commandNameArgument = arguments.unclassifiedArguments.first else {
            return fallbackCommand
        }
        
        if let command = commands.first(where: { $0.name == commandNameArgument.value }) {
            commandNameArgument.classification = .commandName
            return command
        }
        
        if commandNameArgument.value.hasPrefix("-") {
            if let shortcutCommand = commands.first(where: { $0.shortcut == commandNameArgument.value }) {
                commandNameArgument.classification = .commandName
                return shortcutCommand
            }
        }
        
        return fallbackCommand
    }
    
}
