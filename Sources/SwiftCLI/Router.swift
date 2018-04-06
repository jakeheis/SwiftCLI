//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol Router {
    func route(cli: CLI, arguments: ArgumentList) -> RouteResult
}

// MARK: - DefaultRouter

public enum RouteResult {
    case success(CommandPath)
    case failure(partialPath: CommandGroupPath, notFound: String?)
}

public class DefaultRouter: Router {
    
    public init() {}
    
    public func route(cli: CLI, arguments: ArgumentList) -> RouteResult {
        var path = CommandGroupPath(top: cli)
        while let node = arguments.head {
            let value = path.bottom.aliases[node.value] ?? node.value
            if let matching = path.bottom.children.first(where: { $0.name == value }) {
                arguments.remove(node: node)
                if let command = matching as? Command {
                    return .success(path.appending(command))
                } else if let group = matching as? CommandGroup {
                    path = path.appending(group)
                } else {
                    assertionFailure("Routables must either be Commands or Groups")
                }
            } else {
                return .failure(partialPath: path, notFound: node.value)
            }
        }
        
        return .failure(partialPath: path, notFound: nil)
    }
    
}

/// For use if the CLI functions as a single command, e.g. cat someFile
public class SingleCommandRouter: Router {
    
    let command: Command
    
    public init(command: Command) {
        self.command = command
    }
    
    public func route(cli: CLI, arguments: ArgumentList) -> RouteResult {
        return .success(CommandGroupPath(top: cli).appending(command))
    }
    
}
