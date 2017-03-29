//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class OptionRegistry {
    
    private let flags: [String: Flag]
    private let keys: [String: AnyKey]
    private let all: [Option]
    private let groups: [OptionGroup]
    
    init(command: Command) {
        var flags: [String: Flag] = [:]
        var keys: [String: AnyKey] = [:]
        var all: [Option] = []
        for (_, option) in command.options {
            if let flag = option as? Flag {
                for name in flag.names {
                    flags[name] = flag
                }
            } else if let key = option as? AnyKey {
                for name in key.names {
                    keys[name] = key
                }
            }
            all.append(option)
        }
        self.flags = flags
        self.keys = keys
        self.all = all
        self.groups = command.optionGroups
    }
    
    func flag(for key: String) -> Flag? {
        if let flag = flags[key] {
            incrementCount(for: flag)
            return flag
        }
        return nil
    }
    
    func key(for key: String) -> AnyKey? {
        if let key = keys[key] {
            incrementCount(for: key)
            return key
        }
        return nil
    }
    
    func incrementCount(for option: Option) {
        for group in groups {
            if group.options.contains(where: { $0.names == option.names }) {
                group.count += 1
                break
            }
        }
    }
    
    func failingGroup() -> OptionGroup? {
        for group in groups {
            if !group.check() {
                return group
            }
        }
        return nil
    }
    
}

public class OptionGroup {
    
    enum Restriction {
        case atMostOne // 0 or 1
        case exactlyOne // 1
        case atLeastOne // 1 or more
    }
    
    let options: [Option]
    let restriction: Restriction
    
    var message: String {
        let names = options.flatMap({ $0.names.first }).joined(separator: " ")
        var str = "Must pass "
        switch restriction {
        case .exactlyOne:
            str += "exactly one of"
        case .atLeastOne:
            str += "at least one of"
        case .atMostOne:
            str += "at most one of"
        }
        str += ": \(names)"
        return str
    }
    
    fileprivate var count: Int = 0
    
    init(options: [Option], restriction: Restriction) {
        self.options = options
        self.restriction = restriction
    }
    
    func check() -> Bool  {
        if count == 0 && restriction != .atMostOne {
            return false
        }
        if count > 1 && restriction != .atLeastOne {
            return false
        }
        return true
    }
    
}

public protocol Option {
    var names: [String] { get }
    var usage: String { get }
}

public class Flag: Option {
    
    public let names: [String]
    public private(set) var value = false
    public let usage: String
    
    public init(_ names: String ..., usage: String = "") {
        self.names = names
        
        var optionsString = names.joined(separator: ", ")
        let spacing = String(repeating: " ", count: 40 - optionsString.characters.count)
        self.usage = "\(optionsString)\(spacing)\(usage)"
    }
    
    func setOn() {
        value = true
    }
    
}

enum KeyError: Swift.Error {
    case illegalKeyValue
}

public class Key<T: Keyable>: Option {
    
    public let names: [String]
    public private(set) var value: T?
    public let usage: String
    
    public init(_ names: String ..., usage: String = "") {
        self.names = names
        
        var optionsString = names.joined(separator: ", ")
        optionsString += " <value>"
        let spacing = String(repeating: " ", count: 40 - optionsString.characters.count)
        self.usage = "\(optionsString)\(spacing)\(usage)"
    }
    
    public func setValue(_ value: String) throws {
        guard let value = T.val(from: value) else {
            throw KeyError.illegalKeyValue
        }
        self.value = value
    }
    
}

public protocol Keyable {
    static func val(from: String) -> Self?
}

extension String: Keyable {
    public static func val(from: String) -> String? {
        return from
    }
}

extension Int: Keyable {
    public static func val(from: String) -> Int? {
        return Int(from)
    }
}

extension Float: Keyable {
    public static func val(from: String) -> Float? {
        return Float(from)
    }
}

extension Double: Keyable {
    public static func val(from: String) -> Double? {
        return Double(from)
    }
}

public protocol AnyKey: Option {
    func setValue(_ value: String) throws
}

extension Key: AnyKey {}
