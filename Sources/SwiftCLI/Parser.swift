//
//  Parser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - Parser

public protocol Parser {
    func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> CommandPath
}

final public class DefaultParser: Parser {
    
    public let router: Router
    
    public init(router: Router = DefaultRouter()) {
        self.router = router
    }
    
    public func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> CommandPath {
        let (commandPath, optionRegistry) = try router.route(commandGroup: commandGroup, arguments: arguments)
        try finish(commandPath: commandPath, optionRegistry: optionRegistry, arguments: arguments)
        return commandPath
    }
    
    public func finish(commandPath: CommandPath, optionRegistry: OptionRegistry, arguments: ArgumentList) throws {
        let params = ParameterIterator(command: commandPath)
        
        while arguments.hasNext() {
            if params.isCollecting() || !arguments.nextIsOption() {
                try params.parse(args: arguments)
            } else {
                try optionRegistry.parse(args: arguments, command: commandPath)
            }
        }
        
        try params.finish()
        try optionRegistry.finish(command: commandPath)
    }
    
}
