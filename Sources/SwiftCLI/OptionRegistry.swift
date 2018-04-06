//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

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
    
    public func failingGroup() -> OptionGroup? {
        for group in groups {
            if !group.check() {
                return group
            }
        }
        return nil
    }
    
}
