//
//  Path.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/22/18.
//

public protocol RoutablePath: CustomStringConvertible {
    func joined(separator: String) -> String
}

extension RoutablePath {
    public var description: String {
        return "\(type(of: self))(\(joined(separator: " ")))"
    }
}

public struct CommandGroupPath: RoutablePath {
    
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
    
    public func appending(_ routable: Routable) -> RoutablePath {
        if let cmd = routable as? Command {
            return CommandPath(groupPath: self, command: cmd)
        } else if let group = routable as? CommandGroup {
            return CommandGroupPath(groups: groups + [group])
        }
        fatalError()
    }
    
    public func droppingLast() -> CommandGroupPath {
        return CommandGroupPath(groups: Array(groups.dropLast()))
    }
    
    public func joined(separator: String = " ") -> String {
        return groups.map({ $0.name }).joined(separator: separator)
    }
    
}

public struct CommandPath: RoutablePath {
    
    public let groupPath: CommandGroupPath
    public let command: Command
    public var ignoreName = false
    
    public var options: [Option] {
        return command.options + groupPath.groups.map({ $0.options }).joined()
    }
    
    public var usage: String {
        var message = joined()
        
        if !command.parameters.isEmpty {
            let signature = command.parameters.map({ $0.signature }).joined(separator: " ")
            message += " \(signature)"
        }
        
        if !options.isEmpty {
            message += " [options]"
        }
        
        return message
    }
    
    public init(groupPath: CommandGroupPath, command: Command) {
        self.groupPath = groupPath
        self.command = command
    }
    
    public func joined(separator: String = " ") -> String {
        var str = groupPath.joined(separator: separator)
        if !ignoreName {
            str += separator + command.name
        }
        return str
    }
    
}
