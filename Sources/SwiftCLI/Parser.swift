//
//  Parser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - Parser

public class Parser {
    
    public let router: Router
    public let parameterFiller: ParameterFiller
    
    public init(router: Router = DefaultRouter(), parameterFiller: ParameterFiller = DefaultParameterFiller()) {
        self.router = router
        self.parameterFiller = parameterFiller
    }
    
    public func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> CommandPath {
        let (commandPath, optionRegistry) = try router.parse(commandGroup: commandGroup, arguments: arguments)
        try parameterFiller.parse(commandPath: commandPath, optionRegistry: optionRegistry, arguments: arguments)
        try optionRegistry.finish(command: commandPath)
        return commandPath
    }
    
}

// MARK: - Router

/// Implements a func which uses the first few args to recognize options and route to the appropriate command
public protocol Router {
    func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> (CommandPath, OptionRegistry)
}

public class DefaultRouter: Router {
    
    public init() {}
    
    public func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> (CommandPath, OptionRegistry) {
        let optionRegistry = OptionRegistry(routable: commandGroup)
        var groupPath = CommandGroupPath(top: commandGroup)
        
        while arguments.hasNext() {
            arguments.manipulate { (args) in
                var copy = args
                if let alias = groupPath.bottom.aliases[copy[0]] {
                    copy[0] = alias
                }
                return copy
            }
            
            if arguments.nextIsOption() {
                try optionRegistry.parse(args: arguments, command: nil)
            } else {
                let name = arguments.pop()
                guard let matching = groupPath.bottom.children.first(where: { $0.name == name }) else {
                    throw RouteError(partialPath: groupPath, notFound: name)
                }
                
                optionRegistry.register(matching)
                
                if let group = matching as? CommandGroup {
                    groupPath = groupPath.appending(group)
                } else if let cmd = matching as? Command {
                    return (groupPath.appending(cmd), optionRegistry)
                } else {
                    preconditionFailure("Routables must be either CommandGroups or Commands")
                }
            }
        }
        
        if let command = groupPath.bottom as? Command & CommandGroup {
            return (groupPath.droppingLast().appending(command), optionRegistry)
        }
        
        throw RouteError(partialPath: groupPath, notFound: nil)
    }
    
}

public class SingleCommandRouter: Router {
    
    public let command: Command
    
    public init(command: Command) {
        self.command = command
    }
    
    public func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> (CommandPath, OptionRegistry) {
        let path = CommandGroupPath(top: commandGroup).appending(command)
        
        let optionRegistry = OptionRegistry(routable: commandGroup)
        optionRegistry.register(command)
        
        return (path, optionRegistry)
    }
    
}

// MARK: - ParseFinisher

/// Implements a func which uses the remaining args to fill the given command's parameters and options
public protocol ParameterFiller {
    func parse(commandPath: CommandPath, optionRegistry: OptionRegistry, arguments: ArgumentList) throws
}

public class DefaultParameterFiller: ParameterFiller {
    
    public init() {}
    
    public func parse(commandPath: CommandPath, optionRegistry: OptionRegistry, arguments: ArgumentList) throws {
        let params = ParameterIterator(command: commandPath)
        
        while arguments.hasNext() {
            if params.isCollecting() || !arguments.nextIsOption() {
                try params.parse(args: arguments)
            } else {
                try optionRegistry.parse(args: arguments, command: commandPath)
            }
        }
        
        try params.finish()
    }
    
}
