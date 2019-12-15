//
//  Parser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - Parser

@dynamicMemberLookup
public struct Parser {
    
    public struct Configuration {
        public enum RouteBehavior {
            case search
            case searchWithFallback(Command)
            case automatically(Command)
        }
        
        public var routeBehavior: RouteBehavior = .search
        public var parseOptionsAfterCollectedParameter = false
        
        public var fallback: Command? {
            switch routeBehavior {
            case .search: return nil
            case .searchWithFallback(let cmd): return cmd
            case .automatically(let cmd): return cmd
            }
        }
    }

    public struct State {
        
        public enum RouteState {
            case routing(CommandGroupPath)
            case routed(CommandPath, ParameterIterator)
        }
        
        public var routeState: RouteState
        public let optionRegistry: OptionRegistry
        public let configuration: Configuration
        
        public var command: CommandPath? {
            if case let .routed(path, _) = routeState {
                return path
            }
            return nil
        }
        
        public mutating func appendToPath(_ group: CommandGroup) {
            guard case let .routing(current) = routeState else {
                assertionFailure()
                return
            }
            
            optionRegistry.register(group)
            routeState = .routing(current.appending(group))
        }
        
        public mutating func appendToPath(_ cmd: Command, ignoreName: Bool = false) {
            guard case let .routing(current) = routeState else {
                assertionFailure()
                return
            }
            
            optionRegistry.register(cmd)
            var commandPath = current.appending(cmd)
            commandPath.ignoreName = ignoreName
            routeState = .routed(commandPath, ParameterIterator(command: cmd))
        }
        
    }
    
    public var responders: [ParserResponse] = [AliasResponse(), OptionResponse(), RouteResponse(), ParameterResponse()]
    private var configuration = Configuration()
    
    public init() {}
    
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Configuration, U>) -> U {
        get {
            return configuration[keyPath: keyPath]
        }
        set(newValue) {
            configuration[keyPath: keyPath] = newValue
        }
    }
    
    public func parse(cli: CLI, arguments: ArgumentList) throws -> CommandPath {
        var state = Parser.State(
            routeState: .routing(CommandGroupPath(top: cli)),
            optionRegistry: OptionRegistry(routable: cli),
            configuration: configuration
        )
        
        while arguments.hasNext() {
            if let responder = responders.first(where: { $0.canRespond(to: arguments, state: state) }) {
                state = try responder.respond(to: arguments, state: state)
            } else {
                preconditionFailure()
            }
        }
        
        try responders.forEach { (responder) in
            state = try responder.cleanUp(arguments: arguments, state: state )
        }
        
        if let command = state.command {
            return command
        } else {
            preconditionFailure()
        }
    }
    
}

// MARK: - ParserResponse

public protocol ParserResponse {
    func canRespond(to arguments: ArgumentList, state: Parser.State) -> Bool
    func respond(to arguments: ArgumentList, state: Parser.State) throws -> Parser.State
    func cleanUp(arguments: ArgumentList, state: Parser.State) throws -> Parser.State
}

public struct AliasResponse: ParserResponse {
    
    public func canRespond(to arguments: ArgumentList, state: Parser.State) -> Bool {
        if case let .routing(groupPath) = state.routeState,
            groupPath.bottom.aliases[arguments.peek()] != nil {
            return true
        }
        return false
    }
    
    public func respond(to arguments: ArgumentList, state: Parser.State) throws -> Parser.State {
        guard case let .routing(groupPath) = state.routeState else {
            return state
        }
        
        arguments.manipulate { (args) in
            var copy = args
            if let alias = groupPath.bottom.aliases[copy[0]] {
                copy[0] = alias
            }
            return copy
        }
        
        return state
    }
    
    public func cleanUp(arguments: ArgumentList, state: Parser.State) throws -> Parser.State { state }
    
}

public struct OptionResponse: ParserResponse {
    
    public func canRespond(to arguments: ArgumentList, state: Parser.State) -> Bool {
        guard arguments.nextIsOption() else {
            return false
        }
        
        switch state.routeState {
        case .routing(_):
            return state.optionRegistry.recognizesOption(arguments.peek()) || state.configuration.fallback == nil
        case .routed(_, let params):
            return !params.nextIsCollection() || state.configuration.parseOptionsAfterCollectedParameter
        }
    }
    
    public func respond(to arguments: ArgumentList, state: Parser.State) throws -> Parser.State {
        let opt = arguments.pop()
        
        if let flag = state.optionRegistry.flag(for: opt) {
            flag.update()
        } else if let key = state.optionRegistry.key(for: opt) {
             guard arguments.hasNext(), !arguments.nextIsOption() else {
                throw OptionError(command: state.command, kind: .expectedValueAfterKey(opt))
            }
            let updateResult = key.update(to: arguments.pop())
            if case let .failure(error) = updateResult {
               throw OptionError(command: state.command, kind: .invalidKeyValue(key, opt, error))
            }
        } else {
            throw OptionError(command: state.command, kind: .unrecognizedOption(opt))
        }
        
        return state
    }
    
    public func cleanUp(arguments: ArgumentList, state: Parser.State) throws -> Parser.State {
        if let misused = state.optionRegistry.groups.first(where: { !$0.check() }) {
            throw OptionError(command: state.command, kind: .optionGroupMisuse(misused))
        }
        return state
    }
    
}

public struct RouteResponse: ParserResponse {
    
    public func canRespond(to arguments: ArgumentList, state: Parser.State) -> Bool {
        if case .routing = state.routeState {
            return true
        }
        return false
    }
    
    public func respond(to arguments: ArgumentList, state: Parser.State) throws -> Parser.State {
        guard case let .routing(groupPath) = state.routeState else {
            return state
        }
        
        var newState = state
        
        switch state.configuration.routeBehavior {
        case .automatically(let cmd):
            newState.appendToPath(cmd, ignoreName: true)
        case .search, .searchWithFallback(_):
            let name = arguments.peek()
            
            if let matching = groupPath.bottom.children.first(where: { $0.name == name }) {
                arguments.pop()
                                
                if let group = matching as? CommandGroup {
                    newState.appendToPath(group)
                } else if let cmd = matching as? Command {
                    newState.appendToPath(cmd)
                } else {
                    preconditionFailure("Routables must be either CommandGroups or Commands")
                }
            } else if let fallback = state.configuration.fallback {
                newState.appendToPath(fallback, ignoreName: true)
            } else {
                throw RouteError(partialPath: groupPath, notFound: name)
            }
        }
        
        return newState
    }
    
    public func cleanUp(arguments: ArgumentList, state: Parser.State) throws -> Parser.State {
        guard case let .routing(group) = state.routeState else {
            return state
        }
        
        var newState = state
        
        if let fallback = state.configuration.fallback {
            newState.appendToPath(fallback, ignoreName: true)
        } else if let command = group.bottom as? Command & CommandGroup {
            let commandPath = group.droppingLast().appending(command as Command)
            newState.routeState = .routed(commandPath, ParameterIterator(command: command))
        } else {
            throw RouteError(partialPath: group, notFound: nil)
        }
        
        return newState
    }
    
}

public struct ParameterResponse: ParserResponse {

    public func canRespond(to arguments: ArgumentList, state: Parser.State) -> Bool {
        if case .routed = state.routeState {
            return true
        }
        return false
    }
    
    public func respond(to arguments: ArgumentList, state: Parser.State) throws -> Parser.State {
        guard case let .routed(command, params) = state.routeState else {
            return state
        }
        
        if let namedParam = params.next() {
            let result = namedParam.param.update(to: arguments.pop())
            if case let .failure(error) = result {
                throw ParameterError(command: command, kind: .invalidValue(namedParam, error))
            }
        } else {
            throw ParameterError(command: command, kind: .wrongNumber(params.minCount, params.maxCount))
        }
        
        return state
    }
    
    public func cleanUp(arguments: ArgumentList, state: Parser.State) throws -> Parser.State {
        guard case let .routed(command, params) = state.routeState else {
            return state
        }
        
        if let namedParam = params.next(), !namedParam.param.satisfied {
            throw ParameterError(command: command, kind: .wrongNumber(params.minCount, params.maxCount))
        }
        
        return state
    }
    
}
