//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 4/9/18.
//

public protocol Router {
    func route(commandGroup: CommandGroup, arguments: ArgumentList) throws -> (CommandPath, OptionRegistry)
}

public class DefaultRouter: Router {
    
    public init() {}
    
    public func route(commandGroup: CommandGroup, arguments: ArgumentList) throws -> (CommandPath, OptionRegistry) {
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
    
    public func route(commandGroup: CommandGroup, arguments: ArgumentList) throws -> (CommandPath, OptionRegistry) {
        let path = CommandGroupPath(top: commandGroup).appending(command)
        
        let optionRegistry = OptionRegistry(routable: commandGroup)
        optionRegistry.register(command)
        
        return (path, optionRegistry)
    }
    
}

