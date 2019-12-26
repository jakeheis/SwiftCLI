//
//  Option.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

public protocol Option: class, CustomStringConvertible {
    var names: [String] { get }
    var shortDescription: String { get }
    var identifier: String { get }
    var variadic: Bool { get }
}

extension Option {
        
    public var description: String {
        return "\(type(of: self))(\(identifier))"
    }
    
    public var indentedIdentifierLength: Int {
        if names.count == 1 && names[0].hasPrefix("--") { // no one letter shortcut; indent
            return identifier.count + 4
        }
        return identifier.count
    }
    
    public func usage(padding: Int) -> String {
        var id = identifier
        if names.count == 1 && names[0].hasPrefix("--") { // no one letter shortcut; indent
            id = "    " + id
        }
        let spacing = String(repeating: " ", count: padding - id.count)
        let descriptionNewlineSpacing = String(repeating: " ", count: padding)
        let description = shortDescription.replacingOccurrences(of: "\n", with: "\n\(descriptionNewlineSpacing)")
        return "\(id)\(spacing)\(description)"
    }
    
}

// MARK: - Flags

public protocol AnyFlag: Option {
    func update()
}

@propertyWrapper
public class Flag: AnyFlag {
    
    public let names: [String]
    public let shortDescription: String
    public let variadic = false
    
    public private(set) var wrappedValue = false
    public var value: Bool { wrappedValue }
    public var projectedValue: Flag { self }
    
    public var identifier: String {
        return names.joined(separator: ", ")
    }
    
    /// Creates a new flag
    ///
    /// - Parameters:
    ///   - names: the names for the flag; convention is to include a short name (-a) and a long name (--all)
    ///   - description: A short description of what this flag does for usage statements
    public init(_ names: String..., description: String = "") {
        self.names = names.sorted(by: { $0.count < $1.count })
        self.shortDescription = description
    }
    
    /// Toggles the flag's value; don't call directly
    public func update() {
        wrappedValue = true
    }
    
}

@propertyWrapper
public class CounterFlag: AnyFlag {
    
    public let names: [String]
    public let shortDescription: String
    public let variadic = true
    
    public private(set) var wrappedValue: Int = 0
    public var value: Int { wrappedValue }
    public var projectedValue: CounterFlag { self }
    
    public var identifier: String {
        return names.joined(separator: ", ")
    }
    
    /// Creates a new counter flag
    ///
    /// - Parameters:
    ///   - names: the names for the flag; convention is to include a short name (-a) and a long name (--all)
    ///   - description: A short description of what this flag does for usage statements
    public init(_ names: String ..., description: String = "") {
        self.names = names.sorted(by: { $0.count < $1.count })
        self.shortDescription = description
    }
    
    /// Increments the flag's value; don't call directly
    public func update() {
        wrappedValue += 1
    }
    
}

// MARK: - Keys

public protocol AnyKey: Option, AnyValueBox {}

public class _Key<Value: ConvertibleFromString> {
    
    public let names: [String]
    public let shortDescription: String
    public let completion: ShellCompletion
    public let validation: [Validation<Value>]
    
    public var identifier: String {
        return names.joined(separator: ", ") + " <value>"
    }
    
    /// Creates a new key
    ///
    /// - Parameters:
    ///   - names: the names for the key; convention is to include a short name (-m) and a long name (--message)
    ///   - description: A short description of what this key does for usage statements
    public init(names: [String], description: String, completion: ShellCompletion, validation: [Validation<Value>] = []) {
        self.names = names.sorted(by: { $0.count < $1.count })
        self.shortDescription = description
        self.completion = completion
        self.validation = validation
    }
    
}

@propertyWrapper
public class Key<Value: ConvertibleFromString>: _Key<Value>, AnyKey, ValueBox {
    
    public let variadic = false
    
    public private(set) var wrappedValue: Value?
    public var value: Value? { wrappedValue }
    public var projectedValue: Key { self }
    
    public init(_ names: String ..., description: String = "", completion: ShellCompletion = .filename, validation: [Validation<Value>] = []) {
        super.init(names: names, description: description, completion: completion, validation: validation)
    }
    
    public func update(to value: Value) {
        self.wrappedValue = value
    }
    
}

@propertyWrapper
public class VariadicKey<Value: ConvertibleFromString>: _Key<Value>, AnyKey, ValueBox {
    
    public let variadic = true
    
    public private(set) var wrappedValue: [Value] = []
    public var value: [Value] { wrappedValue }
    public var projectedValue: VariadicKey { self }
    
    public init(_ names: String ..., description: String = "", completion: ShellCompletion = .filename, validation: [Validation<Value>] = []) {
        super.init(names: names, description: description, completion: completion, validation: validation)
    }
    
    public func update(to value: Value) {
        self.wrappedValue.append(value)
    }
    
}
