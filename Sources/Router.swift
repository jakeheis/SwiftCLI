//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol Router {
    func route(commands: [Command], arguments: ArgumentList) -> Command?
}

// MARK: - DefaultRouter

public class DefaultRouter: Router {
    
    public func route(commands: [Command], arguments: ArgumentList) -> Command? {
        guard let commandNameArgument = arguments.head else {
            return nil
        }
        
        if let command = commands.first(where: { $0.name == commandNameArgument.value }) {
            arguments.remove(node: commandNameArgument)
            return command
        }
        
        return nil
    }
    
}

/// For use if the CLI functions as a single command, e.g. cat someFile
public class SingleCommandRouter: Router {
    
    let command: Command
    
    public init(command: Command) {
        self.command = command
    }
    
    public func route(commands: [Command], arguments: ArgumentList) -> Command? {
        return command
    }
    
}
