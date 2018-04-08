//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public struct OptionError: Swift.Error {
    let command: CommandPath?
    let message: String
}

public class OptionRegistry {
    
    private var flags: [String: Flag]
    private var keys: [String: AnyKey]
    private var groups: [OptionGroup]
    
    public init(routable: Routable) {
        self.flags = [:]
        self.keys = [:]
        self.groups = []
        
        register(routable)
    }
    
    public func register(_ routable: Routable) {
        for option in routable.options {
            if let flag = option as? Flag {
                for name in flag.names {
                    flags[name] = flag
                }
            } else if let key = option as? AnyKey {
                for name in key.names {
                    keys[name] = key
                }
            }
        }
        
        groups += routable.optionGroups
    }
    
    public func parse(node: ArgumentNode, command: CommandPath?) throws {
        if let flag = flag(for: node.value) {
            flag.setOn()
        } else if let key = key(for: node.value) {
            guard let next = node.next, !next.value.hasPrefix("-") else {
                throw OptionError(command: command, message: "Expected a value to follow: \(node.value)")
            }
            guard key.updateValue(next.value) else {
                throw OptionError(command: command, message: "Illegal type passed to \(key.names.first!): '\(next.value)'")
            }
            next.remove()
        } else {
            throw OptionError(command: command, message:"Unrecognized option: \(node.value)")
        }
    }
    
    public func finish(command: CommandPath) throws {
        if let failingGroup = failingGroup() {
            throw OptionError(command: command, message: failingGroup.message)
        }
    }
    
    // MARK: - Helpers
    
    public func flag(for key: String) -> Flag? {
        if let flag = flags[key] {
            incrementCount(for: flag)
            return flag
        }
        return nil
    }
    
    public func key(for key: String) -> AnyKey? {
        if let key = keys[key] {
            incrementCount(for: key)
            return key
        }
        return nil
    }
    
    private func incrementCount(for option: Option) {
        for group in groups {
            if group.options.contains(where: { $0.names == option.names }) {
                group.count += 1
                break
            }
        }
    }
    
    private func failingGroup() -> OptionGroup? {
        for group in groups {
            if !group.check() {
                return group
            }
        }
        return nil
    }
    
}
