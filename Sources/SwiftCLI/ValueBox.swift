//
//  ValueBox.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 12/27/18.
//

public enum UpdateResult {
    case success
    case failure(InvalidValueReason)
}

public enum InvalidValueReason {
    case conversionError
    case validationError(AnyValidation)
}

// MARK: -

public protocol AnyValueBox: class {
    var completion: ShellCompletion { get }
    var valueType: ConvertibleFromString.Type { get }
    
    func update(to value: String) -> UpdateResult
}

public protocol ValueBox: AnyValueBox {
    associatedtype Value: ConvertibleFromString
    
    var validation: [Validation<Value>] { get }
    
    func update(to value: Value)
}

extension ValueBox {
    
    public var valueType: ConvertibleFromString.Type { return Value.self }
    
    public func update(to value: String) -> UpdateResult {
        guard let converted = Value(input: value) else {
            return .failure(.conversionError)
        }
        
        if let failedValidation = validation.first(where: { $0.validate(converted) == false }) {
            return .failure(.validationError(failedValidation))
        }
        
        update(to: converted)
        
        return .success
    }
    
}

// MARK: - ConvertibleFromString

/// A type that can be created from a string
public protocol ConvertibleFromString {
    
    /// Returns an instance of the conforming type from a string representation
    init?(input: String)
    
    static var explanationForConversionFailure: String { get }
    
    static func messageForInvalidValue(reason: InvalidValueReason, for id: String?) -> String
}

extension ConvertibleFromString {
    public static var explanationForConversionFailure: String {
        return "expected \(self)"
    }
    
    public static func messageForInvalidValue(reason: InvalidValueReason, for id: String?) -> String {
        var message = "invalid value"
        if let id = id {
            message += " passed to '\(id)'"
        }
        
        message += "; "
        
        switch reason {
        case .conversionError: message += explanationForConversionFailure
        case let .validationError(validation): message += validation.message
        }
        
        return message
    }
    
}

extension CaseIterable where Self: ConvertibleFromString {
    public static var explanationForConversionFailure: String {
        let options = allCases.map({ String(describing: $0) }).joined(separator: ", ")
        return "expected one of: \(options)"
    }
}

extension LosslessStringConvertible where Self: ConvertibleFromString {
    public init?(input: String) {
        guard let val = Self(input) else {
            return nil
        }
        self = val
    }
}

extension RawRepresentable where Self: ConvertibleFromString, Self.RawValue: ConvertibleFromString {
    public init?(input: String) {
        guard let raw = RawValue(input: input), let val = Self(rawValue: raw) else {
            return nil
        }
        self = val
    }
}

extension Optional: ConvertibleFromString where Wrapped: ConvertibleFromString {
    
    public static var explanationForConversionFailure: String {
        return Wrapped.explanationForConversionFailure
    }
    
    public static func messageForInvalidValue(reason: InvalidValueReason, for id: String?) -> String {
        return Wrapped.messageForInvalidValue(reason: reason, for: id)
    }
    
    public init?(input: String) {
        if let wrapped = Wrapped(input: input) {
            self = .some(wrapped)
        } else {
            return nil
        }
    }
}

public protocol OptionType {
    associatedtype Wrapped
    static var swiftcli_Empty: Self { get }
    
    var swiftcli_Value: Wrapped? { get }
}
extension Optional: OptionType {
    public static var swiftcli_Empty: Self { .none }
    
    public var swiftcli_Value: Wrapped? {
        if case .some(let value) = self {
            return value
        }
        return nil
    }
}

extension String: ConvertibleFromString {}
extension Int: ConvertibleFromString {}
extension Float: ConvertibleFromString {}
extension Double: ConvertibleFromString {}

extension Bool: ConvertibleFromString {
    
    /// Returns a bool from a string representation
    ///
    /// - parameter input: A string representation of a bool value
    ///
    /// This is case insensitive and recognizes several representations:
    ///
    /// - true/false
    /// - t/f
    /// - yes/no
    /// - y/n
    public init?(input: String) {
        let lowercased = input.lowercased()
        
        if ["y", "yes", "t", "true"].contains(lowercased) {
            self = true
        } else if ["n", "no", "f", "false"].contains(lowercased) {
            self = false
        } else {
            return nil
        }
    }
    
}
