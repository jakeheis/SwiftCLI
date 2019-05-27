//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class OptionRegistry {
    
    private var flags: [String: AnyFlag]
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
            if let flag = option as? AnyFlag {
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
    
    public func recognizesOption(_ opt: String) -> Bool {
        return flags[opt] != nil || keys[opt] != nil
    }
    
    public func parseOneOption(args: ArgumentList, command: CommandPath?) throws {
        let opt = args.pop()
        
        if let flag = flag(for: opt) {
            flag.update()
        } else if let key = key(for: opt) {
             guard args.hasNext(), !args.nextIsOption() else {
                throw OptionError(command: command, kind: .expectedValueAfterKey(opt))
            }
            let updateResult = key.update(to: args.pop())
            if case let .failure(error) = updateResult {
               throw OptionError(command: command, kind: .invalidKeyValue(key, opt, error))
            }
        } else {
            throw OptionError(command: command, kind: .unrecognizedOption(opt))
        }
    }
    
    public func checkGroups(command: CommandPath) throws {
        for group in groups {
            if !group.check() {
                throw OptionError(command: command, kind: .optionGroupMisuse(group))
            }
        }
    }
    
    // MARK: - Helpers
    
    public func flag(for key: String) -> AnyFlag? {
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
            if group.options.contains(where: { $0 === option }) {
                group.count += 1
            }
        }
    }
    
}
