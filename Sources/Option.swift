//
//  Option.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//
//

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
    
    public func setValue(_ value: String) -> Bool {
        guard let value = T.val(from: value) else {
            return false
        }
        self.value = value
        return true
    }
    
}

// MARK: - OptionGroup

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
    
    var count: Int = 0
    
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
