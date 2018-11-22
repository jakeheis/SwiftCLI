//
//  Validation.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 11/21/18.
//

public struct Validation<T> {
    
    public typealias ValidatorBlock = (T) -> Bool
    
    public static func custom(_ validator: @escaping ValidatorBlock, _ message: String) -> Validation {
        return .init(validator, message)
    }
    
    public let block: ValidatorBlock
    public let message: String
    
    init(_ block: @escaping ValidatorBlock, _ message: String) {
        self.block = block
        self.message = message
    }
    
    public func validate(_ value: T) throws {
        guard block(value) else {
            throw UpdateError.validationError(message)
        }
    }
    
}

public extension Validation where T: Equatable {
    
    public static func allowing(_ values: T..., message: String? = nil) -> Validation {
        let commaSeparated = values.map({ String(describing: $0) }).joined(separator: ", ")
        return .init({ values.contains($0) }, message ?? "Must be one of: \(commaSeparated)")
    }
    
    public static func rejecting(_ values: T..., message: String? = nil) -> Validation {
        let commaSeparated = values.map({ String(describing: $0) }).joined(separator: ", ")
        return .init({ !values.contains($0) }, message ?? "Must not be: \(commaSeparated)")
    }
    
}

public extension Validation where T: Comparable {
    
    public static func greaterThan(_ value: T, message: String? = nil) -> Validation {
        return .init({ $0 > value }, message ?? "Must be greater than \(value)")
    }
    
    public static func lessThan(_ value: T, message: String? = nil) -> Validation {
        return .init({ $0 < value }, message ?? "Must be greater than \(value)")
    }
    
    public static func within(_ range: ClosedRange<T>, message: String? = nil) -> Validation {
        return .init({ range.contains($0) }, message ?? "Must be greater than or equal to \(range.lowerBound) and less than or equal to \(range.upperBound)")
    }
    
    public static func within(_ range: Range<T>, message: String? = nil) -> Validation {
        return .init({ range.contains($0) }, message ?? "Must be greater than or equal to \(range.lowerBound) and less than \(range.upperBound)")
    }
    
}

public extension Validation where T == String {
    
    public static func contains(_ substring: String, message: String? = nil) -> Validation {
        return .init({ $0.contains(substring) }, message ?? "Must contain '\(substring)'")
    }
    
}
