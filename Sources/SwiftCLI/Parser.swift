//
//  Parser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - Parser

public class Parser {
    
    public enum RouteBehavior {
        case search
        case searchWithFallback(Command)
        case automatically(Command)
        
        var fallback: Command? {
            switch self {
            case .search: return nil
            case .searchWithFallback(let cmd): return cmd
            case .automatically(let cmd): return cmd
            }
        }
    }
    
    private enum State {
        case routing(CommandGroupPath)
        case routed(CommandPath, ParameterIterator)
        
        var command: CommandPath? {
            if case let .routed(path, _) = self {
                return path
            }
            return nil
        }
    }
    
    public var parseOptionsAfterCollectedParameter = false
    public var routeBehavior: RouteBehavior = .search
    
    public init() {}
    
    public func parse(cli: CLI, arguments: ArgumentList) throws -> CommandPath {
        let optionRegistry = OptionRegistry(routable: cli)
        
        var state: State = .routing(CommandGroupPath(top: cli))
        
        while arguments.hasNext() {
            if shouldParseOption(state: state, arguments: arguments, optionRegistry: optionRegistry) {
                try optionRegistry.parseOneOption(args: arguments, command: state.command)
                continue
            }
            
            switch state {
            case .routing(let groupPath):
                state = try route(groupPath: groupPath, arguments: arguments, optionRegistry: optionRegistry)
            case .routed(let commandPath, let params):
                if let namedParam = params.next() {
                    let result = namedParam.param.update(to: arguments.pop())
                    if case let .failure(error) = result {
                        throw ParameterError(command: commandPath, kind: .invalidValue(namedParam, error))
                    }
                } else {
                    throw ParameterError(command: commandPath, kind: .wrongNumber(params.minCount, params.maxCount))
                }
            }
        }
        
        if case let .routing(group) = state, let fallback = routeBehavior.fallback {
            var command = group.appending(fallback)
            command.ignoreName = true
            state = .routed(command, ParameterIterator(command: command))
        }
        
        let commandPath: CommandPath
        
        switch state {
        case .routing(let groupPath):
            if let command = groupPath.bottom as? Command & CommandGroup {
                commandPath = groupPath.droppingLast().appending(command)
            } else {
                throw RouteError(partialPath: groupPath, notFound: nil)
            }
        case .routed(let path, let params):
            if let namedParam = params.next(), !namedParam.param.satisfied {
                throw ParameterError(command: path, kind: .wrongNumber(params.minCount, params.maxCount))
            }
            commandPath = path
        }
        
        try optionRegistry.checkGroups(command: commandPath)
        
        return commandPath
    }
    
    private func shouldParseOption(state: State, arguments: ArgumentList, optionRegistry: OptionRegistry) -> Bool {
        guard arguments.nextIsOption() else {
            return false
        }
        
        switch state {
        case .routing(let groupPath):
            if optionRegistry.recognizesOption(arguments.peek()) {
                return true
            } else if case .search = routeBehavior, groupPath.bottom.aliases[arguments.peek()] == nil {
                return true
            }
            return false
        case .routed(_, let params):
            return !params.nextIsCollection() || parseOptionsAfterCollectedParameter
        }
    }
    
    private func route(groupPath: CommandGroupPath, arguments: ArgumentList, optionRegistry: OptionRegistry) throws -> Parser.State {
        switch routeBehavior {
        case .automatically(let cmd):
            var cmdPath = groupPath.appending(cmd)
            cmdPath.ignoreName = true
            optionRegistry.register(cmd)
            return .routed(cmdPath, ParameterIterator(command: cmdPath))
        case .search, .searchWithFallback(_):
            arguments.manipulate { (args) in
                var copy = args
                if let alias = groupPath.bottom.aliases[copy[0]] {
                    copy[0] = alias
                }
                return copy
            }
            
            let matching: Routable
            
            let name = arguments.peek()
            
            if let found = groupPath.bottom.children.first(where: { $0.name == name }) {
                matching = found
                arguments.pop()
            } else if let fallback = routeBehavior.fallback {
                optionRegistry.register(fallback)
                var cmdPath = groupPath.appending(fallback)
                cmdPath.ignoreName = true
                return .routed(cmdPath, ParameterIterator(command: cmdPath))
            } else {
                throw RouteError(partialPath: groupPath, notFound: name)
            }
            
            optionRegistry.register(matching)
            
            if let group = matching as? CommandGroup {
                return .routing(groupPath.appending(group))
            } else if let cmd = matching as? Command {
                let cmdPath = groupPath.appending(cmd)
                return .routed(cmdPath, ParameterIterator(command: cmdPath))
            } else {
                preconditionFailure("Routables must be either CommandGroups or Commands")
            }
        }
        
    }
    
}
