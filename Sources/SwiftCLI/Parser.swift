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
    
    public enum State {
        case routing(CommandGroupPath)
        case found(CommandPath, ParameterIterator)
        
        var command: CommandPath? {
            if case let .found(path, _) = self {
                return path
            }
            return nil
        }
    }
    
    public var state: State
    public let arguments: ArgumentList
    public let optionRegistry: OptionRegistry
    
    public init(commandGroup: CommandGroup, arguments: ArgumentList) {
        self.state = .routing(CommandGroupPath(top: commandGroup))
        self.arguments = arguments
        self.optionRegistry = OptionRegistry(routable: commandGroup)
    }
    
    public func parse() throws -> CommandPath {
        while let node = arguments.head {
            if case let .routing(path) = state, let alias = path.bottom.aliases[node.value] {
                node.value = alias
            }
            
            defer { arguments.remove(node: node) }
            
            if node.value.hasPrefix("-") {
                try parseOption(node: node)
                continue
            }
            
            switch state {
            case let .routing(path):
                try route(node: node, path: path)
            case let .found(command, params):
                if let param = params.next() {
                    param.update(value: node.value)
                } else {
                    throw ParameterError(command: command, message: params.createErrorMessage())
                }
            }
        }
        
        switch state {
        case let .routing(path):
            if let command = path.bottom as? Command & CommandGroup {
                return path.droppingLast().appending(command)
            }
            throw RouteError(partialPath: path, notFound: nil)
        case let .found(command, params):
            if let param = params.next(), !param.satisfied {
                throw ParameterError(command: command, message: params.createErrorMessage())
            }
            if let failingGroup = optionRegistry.failingGroup() {
                throw OptionError(command: command, message: failingGroup.message)
            }
            return command
        }
    }
    
    public func parseOption(node: ArgumentNode) throws {
        if let flag = optionRegistry.flag(for: node.value) {
            flag.setOn()
        } else if let key = optionRegistry.key(for: node.value) {
            guard let next = node.next, !next.value.hasPrefix("-") else {
                throw OptionError(command: state.command, message: "Expected a value to follow: \(node.value)")
            }
            guard key.setValue(next.value) else {
                throw OptionError(command: state.command, message: "Illegal type passed to \(key): \(node.value)")
            }
            arguments.remove(node: next)
        } else {
            throw OptionError(command: state.command, message:"Unrecognized option: \(node.value)")
        }
    }
    
    public func route(node: ArgumentNode, path: CommandGroupPath) throws {
        guard let matching = path.bottom.children.first(where: { $0.name == node.value }) else {
            throw RouteError(partialPath: path, notFound: node.value)
        }
        
        optionRegistry.register(matching)
        
        if let group = matching as? CommandGroup {
            state = .routing(path.appending(group))
        } else if let cmd = matching as? Command {
            let params = ParameterIterator(command: cmd)
            state = .found(path.appending(cmd), params)
        } else {
            preconditionFailure("Routables must be either CommandGroups or Commands")
        }
    }
    
}
