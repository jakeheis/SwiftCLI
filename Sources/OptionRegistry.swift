//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class OptionRegistry {
    
    let flags: [String: Flag]
    let keys: [String: AnyKey]
    let all: [Option]
    
    init(command: OptionCommand) {
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
