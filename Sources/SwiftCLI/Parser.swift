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

public struct OptionError: Swift.Error {
    let command: CommandPath?
    let message: String
}

public struct ParameterError: Swift.Error {
    let command: CommandPath
    let message: String
}

public protocol Parser {
    init(commandGroup: CommandGroup, arguments: ArgumentList)
    func parse() throws -> CommandPath
}

final public class DefaultParser: Parser {
    
    let commandGroup: CommandGroup
    let arguments: ArgumentList
    private(set) var groupPath: CommandGroupPath
    let optionRegistry: OptionRegistry
    
    var command: CommandPath? = nil
    var params: ParameterIterator? = nil
    
    public init(commandGroup: CommandGroup, arguments: ArgumentList) {
        self.commandGroup = commandGroup
        self.arguments = arguments
        self.groupPath = CommandGroupPath(top: commandGroup)
        self.optionRegistry = OptionRegistry(routable: commandGroup)
    }
    
    public func parse() throws -> CommandPath {
        while let node = arguments.head {
            if let alias = groupPath.bottom.aliases[node.value] {
                node.value = alias
            }
            
            defer { arguments.remove(node: node) }
            
            if node.value.hasPrefix("-") {
                try parseOption(node: node)
                continue
            }
            
            if let command = command, let params = params {
                if let param = params.next() {
                    param.update(value: node.value)
                } else {
                    throw ParameterError(command: command, message: params.createErrorMessage())
                }
            } else {
                try route(node: node)
            }
        }
        
        guard let commandPath = command else {
            throw RouteError(partialPath: groupPath, notFound: nil)
        }
        if let params = params, let param = params.next(), !param.satisfied {
            throw ParameterError(command: commandPath, message: params.createErrorMessage())
        }
        if let failingGroup = optionRegistry.failingGroup() {
            throw OptionError(command: commandPath, message: failingGroup.message)
        }
        
        return commandPath
    }
    
    func parseOption(node: ArgumentNode) throws {
        if let flag = optionRegistry.flag(for: node.value) {
            flag.setOn()
        } else if let key = optionRegistry.key(for: node.value) {
            guard let next = node.next, !next.value.hasPrefix("-") else {
                throw OptionError(command: command, message: "Expected a value to follow: \(node.value)")
            }
            guard key.setValue(next.value) else {
                throw OptionError(command: command, message: "Illegal type passed to \(key): \(node.value)")
            }
            arguments.remove(node: next)
        } else {
            throw OptionError(command: command, message:"Unrecognized option: \(node.value)")
        }
    }
    
    func route(node: ArgumentNode) throws {
        guard let matching = groupPath.bottom.children.first(where: { $0.name == node.value }) else {
            throw RouteError(partialPath: groupPath, notFound: node.value)
        }
        
        optionRegistry.register(matching)
        
        if let group = matching as? CommandGroup {
            groupPath = groupPath.appending(group)
        } else if let cmd = matching as? Command {
            command = groupPath.appending(cmd)
            params = ParameterIterator(command: cmd)
        } else {
            preconditionFailure("Routables must be either CommandGroups or Commands")
        }
    }
    
}
