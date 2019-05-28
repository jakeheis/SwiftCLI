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
        guard let converted = Value.convert(from: value) else {
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
    static func convert(from: String) -> Self?
    
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

