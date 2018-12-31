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
}

public extension Option {
        
    var description: String {
        return "\(type(of: self))(\(identifier))"
    }
    
    func usage(padding: Int) -> String {
        let spacing = String(repeating: " ", count: padding - identifier.count)
        let descriptionNewlineSpacing = String(repeating: " ", count: padding)
        let description = shortDescription.replacingOccurrences(of: "\n", with: "\n\(descriptionNewlineSpacing)")
        return "\(identifier)\(spacing)\(description)"
    }
    
}

public class Flag: Option {
    
    public let names: [String]
    public let shortDescription: String
    public private(set) var value: Bool
    
    public var identifier: String {
        return names.joined(separator: ", ")
    }
    
    /// Creates a new flag
    ///
    /// - Parameters:
    ///   - names: the names for the flag; convention is to include a short name (-a) and a long name (--all)
    ///   - description: A short description of what this flag does for usage statements
    ///   - defaultValue: the default value of this flag; default false
    public init(_ names: String ..., description: String = "", defaultValue: Bool = false) {
        self.names = names
        self.value = defaultValue
        self.shortDescription = description
    }
    
    /// Toggles the flag's value; don't call directly
    public func toggle() {
        value = !value
    }
    
}

public protocol AnyKey: Option, AnyValueBox {}

public class _Key<Value: ConvertibleFromString> {
    
    public let names: [String]
    public let shortDescription: String
    public let completion: Completion
    public let validation: [Validation<Value>]
    
    public var identifier: String {
        return names.joined(separator: ", ") + " <value>"
    }
    
    /// Creates a new key
    ///
    /// - Parameters:
    ///   - names: the names for the key; convention is to include a short name (-m) and a long name (--message)
    ///   - description: A short description of what this key does for usage statements
    public init(_ names: [String], description: String, completion: Completion, validation: [Validation<Value>] = []) {
        self.names = names
        self.shortDescription = description
        self.completion = completion
        self.validation = validation
    }
    
}

public class Key<Value: ConvertibleFromString>: _Key<Value>, AnyKey, ValueBox {
    
    public var value: Value?
    
    public override init(_ names: String ..., description: String = "", completion: Completion = .filename, validation: [Validation<Value>] = []) {
        super.init(names, description: description, completion: completion, validation: validation)
    }
    
    public func update(to value: Value) {
        self.value = value
    }
    
}

public class VariadicKey<Value: ConvertibleFromString>: _Key<Value>, AnyKey, ValueBox {
    
    public var value: [Value] = []
    
    public override init(_ names: String ..., description: String = "", completion: Completion = .filename, validation: [Validation<Value>] = []) {
        super.init(names, description: description, completion: completion, validation: validation)
    }
    
    public func update(to value: Value) {
        self.value.append(value)
    }
    
}
