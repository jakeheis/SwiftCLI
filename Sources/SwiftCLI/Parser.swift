//
//  Parser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - Parser

public struct RouteError: Swift.Error {
    public let partialPath: CommandGroupPath
    public let notFound: String?
}

public protocol Parser {
    func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> CommandPath
}

final public class DefaultParser: Parser {
    
    public func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> CommandPath {
        let (commandPath, optionRegistry) = try route(commandGroup: commandGroup, arguments: arguments)
        let params = ParameterIterator(command: commandPath)
        
        while let node = arguments.head {
            if isOption(node) {
                try optionRegistry.parse(node: node, command: commandPath)
            } else {
                try params.parse(node: node)
            }
            
            node.remove()
        }
        
        try params.finish()
        try optionRegistry.finish(command: commandPath)
        
        return commandPath
    }
    
    public func route(commandGroup: CommandGroup, arguments: ArgumentList) throws -> (CommandPath, OptionRegistry) {
        let optionRegistry = OptionRegistry(routable: commandGroup)
        var groupPath = CommandGroupPath(top: commandGroup)
        
        while let node = arguments.head {
            if let alias = groupPath.bottom.aliases[node.value] {
                node.value = alias
            }
            
            defer { node.remove() }
            
            if isOption(node) {
                try optionRegistry.parse(node: node, command: nil)
            } else {
                guard let matching = groupPath.bottom.children.first(where: { $0.name == node.value }) else {
                    throw RouteError(partialPath: groupPath, notFound: node.value)
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
    
    private func isOption(_ node: ArgumentNode) -> Bool {
        return node.value.hasPrefix("-")
    }
    
}

final public class SingleCommandParser: Parser {
    
    public let command: Command
    
    public init(command: Command) {
        self.command = command
    }
    
    public func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> CommandPath {
        let path = CommandGroupPath(top: commandGroup).appending(command)
        
        let optionRegistry = OptionRegistry(routable: commandGroup)
        optionRegistry.register(command)
        
        let params = ParameterIterator(command: path)
        
        while let node = arguments.head {
            defer { node.remove() }
            
            if node.value.hasPrefix("-") {
                try optionRegistry.parse(node: node, command: path)
            } else {
                try params.parse(node: node)
            }
        }
        
        return path
    }
    
}
