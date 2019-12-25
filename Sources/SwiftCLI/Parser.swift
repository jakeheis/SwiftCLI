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
        
        /// The route behavior to use to find the specified command; default .search
        public var routeBehavior: RouteBehavior = .search
        
        /// Continue parsing options after a collected parameter is encountered; default false
        public var parseOptionsAfterCollectedParameter = false
        
        /// Split options joined in one argument, e.g. split '-am' into '-a' and '-m'; default true
        public var splitJoinedOptions = true
        
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
        get { configuration[keyPath: keyPath] }
        set { configuration[keyPath: keyPath] = newValue }
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
        let firstArg = arguments.pop()
        
        if firstArg.hasPrefix("--"), let equalsIndex = firstArg.firstIndex(of: "=") {
            let optName = String(firstArg[..<equalsIndex])
            let value = String(firstArg[firstArg.index(after: equalsIndex)...])
            
            try parse(option: optName, associatedValue: .required(value), arguments: arguments, state: state)
        } else if firstArg.hasPrefix("-") && !firstArg.hasPrefix("--") && state.configuration.splitJoinedOptions {
            let options = firstArg.dropFirst().map({ "-\($0)" })
            for option in options.dropLast() {
                try parse(option: option, associatedValue: .none, arguments: arguments, state: state)
            }
            try parse(option: options.last!, associatedValue: .unknown, arguments: arguments, state: state)
        } else {
            try parse(option: firstArg, associatedValue: .unknown, arguments: arguments, state: state)
        }
        
        return state
    }
    
    private enum AssociatedValue {
        case required(String)
        case unknown
        case none
    }
    
    private func parse(option: String, associatedValue: AssociatedValue, arguments: ArgumentList, state: Parser.State) throws {
        if let flag = state.optionRegistry.flag(for: option) {
            if case .required(_) = associatedValue {
                throw OptionError(command: state.command, kind: .unexpectedValueAfterFlag(option))
            }
            flag.update()
        } else if let key = state.optionRegistry.key(for: option) {
            let value: String
            switch associatedValue {
            case .required(let val):
                value = val
            case .unknown:
                guard arguments.hasNext(), !arguments.nextIsOption() else {
                    fallthrough
                }
                value = arguments.pop()
            case .none:
                throw OptionError(command: state.command, kind: .expectedValueAfterKey(option))
            }
            
            let updateResult = key.update(to: value)
            if case let .failure(error) = updateResult {
               throw OptionError(command: state.command, kind: .invalidKeyValue(key, option, error))
            }
        } else {
            throw OptionError(command: state.command, kind: .unrecognizedOption(option))
        }
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
