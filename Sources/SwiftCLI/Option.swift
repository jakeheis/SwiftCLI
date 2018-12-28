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
    var isVariadic: Bool { get }
    var completion: Completion? { get }
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
    public let isVariadic = false
    public let completion: Completion? = nil
    
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

public enum UpdateResult {
    case success
    case failure(ProcessingError)
}

public protocol AnyKey: Option {
    var valueType: ConvertibleFromString.Type { get }
    
    func updateValue(_ value: String) -> UpdateResult
}

public class Key<T: ConvertibleFromString>: AnyKey {
        
    public let names: [String]
    public let shortDescription: String
    public private(set) var value: T?
    public let isVariadic = false
    public let completion: Completion?
    public let validation: [Validation<T>]
    
    public var valueType: ConvertibleFromString.Type {
        return T.self
    }
    
    public var identifier: String {
        return names.joined(separator: ", ") + " <value>"
    }
    
    /// Creates a new key
    ///
    /// - Parameters:
    ///   - names: the names for the key; convention is to include a short name (-m) and a long name (--message)
    ///   - description: A short description of what this key does for usage statements
    public init(_ names: String ..., description: String = "", completion: Completion = .filename, validation: [Validation<T>] = []) {
        self.names = names
        self.shortDescription = description
        self.completion = completion
        self.validation = validation
    }
    
    /// Toggles the key's value; don't call directly
    public func updateValue(_ value: String) -> UpdateResult {
        let (result, potentialValue) = T.convertAndValidate(value: value, validation: validation)
        if let value = potentialValue {
            self.value = value
        }
        return result
    }
    
}

public class VariadicKey<T: ConvertibleFromString>: AnyKey {
    
    public let names: [String]
    public let shortDescription: String
    public private(set) var values: [T] = []
    public let isVariadic = true
    public let completion: Completion?
    public let validation: [Validation<T>]
    
    public var valueType: ConvertibleFromString.Type {
        return T.self
    }
    
    public var identifier: String {
        return names.joined(separator: ", ") + " <value>"
    }
    
    /// Creates a new variadic key
    ///
    /// - Parameters:
    ///   - names: the names for the key; convention is to include a short name (-m) and a long name (--message)
    ///   - description: A short description of what this key does for usage statements
    public init(_ names: String ..., description: String = "", completion: Completion = .filename, validation: [Validation<T>] = []) {
        self.names = names
        self.shortDescription = description
        self.completion = completion
        self.validation = validation
    }
    
    /// Toggles the key's value; don't call directly
    public func updateValue(_ value: String) -> UpdateResult {
        let (result, potentialValue) = T.convertAndValidate(value: value, validation: validation)
        if let value = potentialValue {
            values.append(value)
        }
        return result
    }
    
}


// MARK: - ConvertibleFromString

public enum ProcessingError {
    case conversionError
    case validationError(AnyValidation)
}

/// A type that can be created from a string
public protocol ConvertibleFromString {
    /// Returns an instance of the conforming type from a string representation
    static func convert(from: String) -> Self?
    
    static var explanationForConversionFailure: String { get }
    
    static func messageForProcessingError(error: ProcessingError, for id: String?) -> String
}

extension ConvertibleFromString {
    
    public static func convertAndValidate(value: String, validation: [Validation<Self>]) -> (UpdateResult, Self?) {
        guard let converted = Self.convert(from: value) else {
            return (.failure(.conversionError), nil)
        }
        for validator in validation {
            if case .failure(_) = validator.validate(converted) {
                return (.failure(.validationError(validator)), nil)
            }
        }
        return (.success, converted)
    }
    
    public static var explanationForConversionFailure: String {
        return "expected \(self)"
    }
    
    public static func messageForProcessingError(error: ProcessingError, for id: String?) -> String {
        var message = "invalid value"
        if let id = id {
            message += " passed to '\(id)'"
        }
        
        message += "; "
        
        switch error {
        case .conversionError: message += explanationForConversionFailure
        case let .validationError(validation): message += validation.message
        }
        
        return message
    }
    
}

#if swift(>=4.1.50)

extension ConvertibleFromString where Self: CaseIterable {
    
    public static var explanationForConversionFailure: String {
        let options = allCases.map({ String(describing: $0) }).joined(separator: ", ")
        return "expected one of: \(options)"
    }

}

#endif

extension ConvertibleFromString where Self: LosslessStringConvertible {
    public static func convert(from: String) -> Self? {
        return Self(from)
    }
}

extension ConvertibleFromString where Self: RawRepresentable, Self.RawValue: ConvertibleFromString {
    public static func convert(from: String) -> Self? {
        guard let val = RawValue.convert(from: from) else {
            return nil
        }
        return Self.init(rawValue: val)
    }
}

extension String: ConvertibleFromString {}
extension Int: ConvertibleFromString {}
extension Float: ConvertibleFromString {}
extension Double: ConvertibleFromString {}

extension Bool: ConvertibleFromString {
    /// Returns a bool from a string representation
    ///
    /// - parameter from: A string representation of a bool value
    ///
    /// This is case insensitive and recognizes several representations:
    ///
    /// - true/false
    /// - t/f
    /// - yes/no
    /// - y/n
    public static func convert(from: String) -> Bool? {
        let lowercased = from.lowercased()
        
        if ["y", "yes", "t", "true"].contains(lowercased) { return true }
        if ["n", "no", "f", "false"].contains(lowercased) { return false }
        
        return nil
    }
}

