//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol Router {
    func route(routables: [Routable], arguments: ArgumentList) -> Command?
}

// MARK: - DefaultRouter

public class DefaultRouter: Router {
    
    public func route(routables: [Routable], arguments: ArgumentList) -> Command? {
        var options = routables
        while let node = arguments.head {
            if let matching = options.first(where: { node.value == $0.name }) {
                arguments.remove(node: node)
                if let command = matching as? Command {
                    return command
                } else if let group = matching as? CommandGroup {
                    options = group.children
                } else {
                    assertionFailure("Routables must either be Commands or Groups")
                }
            } else {
                return nil
            }
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
    
    public func route(routables: [Routable], arguments: ArgumentList) -> Command? {
        return command
    }
    
}
