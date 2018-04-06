//
//  ParameterFiller.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - ParameterFiller

/// Protcol representing an object which parses the arguments for a command from an argument list
public protocol ParameterFiller {
    func fillParameters(of signature: CommandSignature, with arguments: ArgumentList) throws
}

public class Parse {
    
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
    
    enum State {
        case routing(path: CommandGroupPath)
        case fillingParams(path: CommandPath, params: ParameterIterator)
        
        var options: OptionRegistry {
            switch self {
            case let .routing(path: path): return OptionRegistry(options: path.sharedOptions, optionGroups: [])
            case let .fillingParams(path: path, _): return OptionRegistry(options: path.options, optionGroups: path.command.optionGroups)
            }
        }
        
        var groupPath: CommandGroupPath {
            switch self {
            case let .routing(path: path): return path;
            case let .fillingParams(path: path, _): return path.groupPath
            }
        }
        
        var command: CommandPath? {
            switch self {
            case .routing: return nil
            case let .fillingParams(path: path, params: _): return path
            }
        }
    }
    
    private var parameterCount = 0

    func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> CommandPath {
        var state = State.routing(path: CommandGroupPath(top: commandGroup))
        while let next = try step(state: state, arguments: arguments) {
            state = next
        }
        
        switch state {
        case let .routing(path: path):
            throw RouteError(partialPath: path, notFound: nil)
        case let .fillingParams(path: path, params: params):
            if let param = params.next(), !param.satisfied {
                throw ParameterError(command: path, message: params.createErrorMessage())
            }
            if let failingGroup = state.options.failingGroup() {
                throw OptionError(command: path, message: failingGroup.message)
            }
            return path
        }
    }
    
    func step(state: State, arguments: ArgumentList) throws -> State? {
        guard let node = arguments.head else {
            return nil
        }
        
        if case let .routing(path: path) = state, let alias = path.bottom.aliases[node.value] {
            node.value = alias
        }
        
        defer { arguments.remove(node: node) }
        
        if node.value.hasPrefix("-") {
            try handleOption(node: node, arguments: arguments, state: state)
            return state
        }
        
        switch state {
        case let .routing(path: path):
            return try route(path: path, node: node.value)
        case let .fillingParams(path, params):
            try fillParameters(params: params, value: node.value, path: path)
            return state
        }
    }
    
    private func handleOption(node: ArgumentNode, arguments: ArgumentList, state: State) throws {
        let optionRegistry = state.options
        
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
    
    private func route(path: CommandGroupPath, node: String) throws -> State  {
        let value = path.bottom.aliases[node] ?? node
        print("routing for val \(value)")
        guard let matching = path.bottom.children.first(where: { $0.name == value }) else {
            throw RouteError(partialPath: path, notFound: value)
        }
        
        if let group = matching as? CommandGroup {
            return .routing(path: path.appending(group))
        } else if let cmd = matching as? Command {
            print("returning \(path.appending(cmd))")
            return .fillingParams(path: path.appending(cmd), params: ParameterIterator(command: cmd))
        } else {
            preconditionFailure("Routables must be either CommandGroups or Commands")
        }
    }
    
    private func fillParameters(params: ParameterIterator, value: String, path: CommandPath) throws {
        if let param = params.next() {
            param.update(value: value)
        } else {
            throw ParameterError(command: path, message: params.createErrorMessage())
        }
    }
    
}

// MARK: - DefaultParameterFiller

public class DefaultParameterFiller: ParameterFiller {
    
    public init() {}
    
    public func fillParameters(of signature: CommandSignature, with arguments: ArgumentList) throws {
        let gotCount = arguments.count()
        
        // First satisfy required parameters
        for parameter in signature.required {
            guard let next = arguments.head else {
                throw wrongArgCount(signature: signature, got: gotCount)
            }
            parameter.update(value: next.value)
            arguments.remove(node: next)
        }
        
        // Then optional parameters
        for parameter in signature.optional {
            guard let next = arguments.head else {
                break
            }
            parameter.update(value: next.value)
            arguments.remove(node: next)
        }
        
        // Finally collect remaining arguments if need be
        if let collected = signature.collected {
            var last: [String] = []
            while let node = arguments.head {
                last.append(node.value)
                arguments.remove(node: node)
            }
            if last.isEmpty {
                if collected.required {
                    throw wrongArgCount(signature: signature, got: gotCount)
                }
            } else {
                collected.update(value: last)
            }
        }
        
        // ArgumentList should be empty; if not, user passed too many arguments
        if arguments.head != nil {
            throw wrongArgCount(signature: signature, got: gotCount)
        }
    }
    
    func wrongArgCount(signature: CommandSignature, got: Int) -> CLI.Error {
        var requiredCount = signature.required.count
        if signature.collected?.required == true {
            requiredCount += 1
        }
        let optionalCount = signature.optional.count
        
        let plural = requiredCount == 1 ? "argument" : "arguments"
        if signature.collected != nil {
            return CLI.Error(message: "error: command requires at least \(requiredCount) \(plural), got \(got)")
        }
        if optionalCount == 0 {
            return CLI.Error(message: "error: command requires exactly \(requiredCount) \(plural), got \(got)")
        }
        return CLI.Error(message: "error: command requires between \(requiredCount) and \(requiredCount + optionalCount) arguments, got \(got)")
    }
    
}
