import Foundation
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
    func usage(padding: Int) -> String
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

public protocol AnyKey: Option {
    var valueType: Any.Type { get }
    func updateValue(_ value: String) -> UpdateResult
}

public class Key<T: ConvertibleFromString>: AnyKey
        where T.ValidationOption.Element == T {
    private var validation: [T.ValidationOption] = []

    public let names: [String]
    public let shortDescription: String
    public private(set) var value: T?
    public let isVariadic = false

    public var description: String {
        return "\(type(of: self))(\(identifier))"
    }

    public var valueType: Any.Type {
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
    public init(
        _ names: String ...,
        description: String = "",
        validation: [T.ValidationOption] = []
    ) {
        self.names = names
        self.shortDescription = description
        self.validation = validation
    }

    /// Toggles the key's value; don't call directly
    public func updateValue(_ raw: String) -> UpdateResult {
        guard let value = T.convert(from: raw) else {
            return .illegalType
        }

        for item in validation {
            switch item.validate(element: value) {
            case let .failed(message):
                return .validationError(message)
            case .succeeded:
                continue
            }
        }

        self.value = value
        return .succeeded
    }
}

public class VariadicKey<T: ConvertibleFromString>: AnyKey {
    public let names: [String]
    public let shortDescription: String
    public private(set) var values: [T]
    public let isVariadic = true

    public var valueType: Any.Type {
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
    public init(_ names: String ..., description: String = "") {
        self.names = names
        self.shortDescription = description
        self.values = []
    }

    /// Toggles the key's value; don't call directly
    public func updateValue(_ raw: String) -> UpdateResult {
        guard let value = T.convert(from: raw) else {
            return .illegalType
        }
        values.append(value)
        return .succeeded
    }

}

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
