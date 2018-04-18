//
//  Option.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

public protocol Option {
    var names: [String] { get }
    var shortDescription: String { get }
    var identifier: String { get }
}

public extension Option {
    func usage(padding: Int) -> String {
        let spacing = String(repeating: " ", count: padding - identifier.count)
        return "\(identifier)\(spacing)\(shortDescription)"
    }
}

public class Flag: Option {
    
    public let names: [String]
    public let shortDescription: String
    public private(set) var value: Bool
    
    public var identifier: String {
        return names.joined(separator: ", ")
    }
    
    @available(*, unavailable, renamed: "init(_:description:defaultValue:)")
    public init(_ names: String ..., usage: String = "", defaultValue: Bool = false) {
        self.names = names
        self.value = defaultValue
        self.shortDescription = usage
    }
    
    public init(_ names: String ..., description: String = "", defaultValue: Bool = false) {
        self.names = names
        self.value = defaultValue
        self.shortDescription = description
    }
    
    public func setOn() {
        value = true
    }
    
}

public protocol AnyKey: Option {
    func updateValue(_ value: String) -> Bool
}

public class Key<T: ConvertibleFromString>: AnyKey {
    
    public let names: [String]
    public let shortDescription: String
    public private(set) var value: T?
    
    public var identifier: String {
        return names.joined(separator: ", ") + " <value>"
    }
    
    @available(*, unavailable, renamed: "init(_:description:)")
    public init(_ names: String ..., usage: String = "") {
        self.names = names
        self.shortDescription = usage
    }
    
    public init(_ names: String ..., description: String = "") {
        self.names = names
        self.shortDescription = description
    }
    
    public func updateValue(_ value: String) -> Bool {
        guard let value = T.convert(from: value) else {
            return false
        }
        self.value = value
        return true
    }
    
}

public class VariadicKey<T: ConvertibleFromString>: AnyKey {
    
    public let names: [String]
    public let shortDescription: String
    public private(set) var values: [T]
    
    public var identifier: String {
        return names.joined(separator: ", ") + " <value>"
    }
    
    public init(_ names: String ..., description: String = "") {
        self.names = names
        self.shortDescription = description
        self.values = []
    }
    
    public func updateValue(_ value: String) -> Bool {
        guard let value = T.convert(from: value) else {
            return false
        }
        values.append(value)
        return true
    }
    
}

// MARK: - ConvertibleFromString

public protocol ConvertibleFromString {
    static func convert(from: String) -> Self?
}

extension String: ConvertibleFromString {
    public static func convert(from: String) -> String? {
        return from
    }
}

extension Int: ConvertibleFromString {
    public static func convert(from: String) -> Int? {
        return Int(from)
    }
}

extension Float: ConvertibleFromString {
    public static func convert(from: String) -> Float? {
        return Float(from)
    }
}

extension Double: ConvertibleFromString {
    public static func convert(from: String) -> Double? {
        return Double(from)
    }
}

extension Bool: ConvertibleFromString {
    public static func convert(from: String) -> Bool? {
        let lowercased = from.lowercased()
        
        if ["y", "yes", "t", "true"].contains(lowercased) { return true }
        if ["n", "no", "f", "false"].contains(lowercased) { return false }
        
        return nil
    }
}

extension RawRepresentable where RawValue: ConvertibleFromString {
    public static func convert(from: String) -> Self? {
        guard let val = RawValue.convert(from: from) else {
            return nil
        }
        return Self.init(rawValue: val)
    }
}
