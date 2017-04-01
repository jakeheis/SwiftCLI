//
//  Option.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

public protocol Option {
    var names: [String] { get }
    var usage: String { get }
}

extension Option {
    static var usageLength: Int {
        return 40
    }
}

public class Flag: Option {
    
    public let names: [String]
    public private(set) var value: Bool
    public let usage: String
    
    public init(_ names: String ..., usage: String = "", defaultValue: Bool = false) {
        self.names = names
        self.value = defaultValue
        
        let optionsString = names.joined(separator: ", ")
        let spacing = String(repeating: " ", count: Flag.usageLength - optionsString.characters.count)
        self.usage = "\(optionsString)\(spacing)\(usage)"
    }
    
    public func setOn() {
        value = true
    }
    
}

public class Key<T: Keyable>: Option {
    
    public let names: [String]
    public private(set) var value: T?
    public let usage: String
    
    public init(_ names: String ..., usage: String = "") {
        self.names = names
        
        let optionsString = names.joined(separator: ", ") + " <value>"
        let spacing = String(repeating: " ", count: Key.usageLength - optionsString.characters.count)
        self.usage = "\(optionsString)\(spacing)\(usage)"
    }
    
    public func setValue(_ value: String) -> Bool {
        guard let value = T.val(from: value) else {
            return false
        }
        self.value = value
        return true
    }
    
}

// MARK: - AnyKey

public protocol AnyKey: Option {
    func setValue(_ value: String) -> Bool
}

extension Key: AnyKey {}

// MARK: - Keyable

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

extension RawRepresentable where Self: Keyable, RawValue == String {
    public static func val(from: String) -> Self? {
        return Self.init(rawValue: from)
    }
}
