//
//  Path.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/22/18.
//

public struct CommandGroupPath {
    
    public let groups: [CommandGroup]
    
    public var bottom: CommandGroup {
        return groups.last!
    }
    
    public init(top: CommandGroup, groups: [CommandGroup] = []) {
        self.init(groups: [top] + groups)
    }
    
    private init(groups: [CommandGroup]) {
        self.groups = groups
    }
    
    public func appending(_ group: CommandGroup) -> CommandGroupPath {
        return CommandGroupPath(groups: groups + [group])
    }
    
    public func appending(_ command: Command) -> CommandPath {
        return CommandPath(groupPath: self, command: command)
    }
    
    public func droppingLast() -> CommandGroupPath {
        return CommandGroupPath(groups: Array(groups.dropLast()))
    }
    
    public func joined(separator: String = " ") -> String {
        return groups.map({ $0.name }).joined(separator: separator)
    }
    
}

public struct CommandPath {
    
    public let groupPath: CommandGroupPath?
    public let command: Command
    
    public var options: [Option] {
        if let shared = groupPath?.groups.map({ $0.options }).joined() {
            return command.options + shared
        }
        return command.options
    }
    
    var usage: String {
        var message = joined()
        
        if !command.parameters.isEmpty {
            let signature = command.parameters.map({ $0.1.signature(for: $0.0) }).joined(separator: " ")
            message += " \(signature)"
        }
        
        if !options.isEmpty {
            message += " [options]"
        }
        
        return message
    }
    
    public init(groupPath: CommandGroupPath? = nil, command: Command) {
        self.groupPath = groupPath
        self.command = command
    }
    
    public func joined(separator: String = " ") -> String {
        if let group = groupPath?.joined(separator: separator) {
            return group + separator + command.name
        }
        return command.name
    }
    
}
