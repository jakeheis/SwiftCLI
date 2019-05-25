//
//  Validation.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 11/21/18.
//

public struct Validation<T> {
    
    public enum Result {
        case success
        case failure(String)
    }
    
    public typealias ValidatorBlock = (T) -> Bool
    
    public static func custom(_ message: String, _ validator: @escaping ValidatorBlock) -> Validation {
        return .init(message, validator)
    }
    
    public let block: ValidatorBlock
    private let message: String
    
    init(_ message: String, _ block: @escaping ValidatorBlock) {
        self.block = block
        self.message = message
    }
    
    public func validate(_ value: T) -> Result {
        guard block(value) else {
            return .failure(message)
        }
        return .success
    }
    
}

public extension Validation where T: Equatable {
    
    static func allowing(_ values: T..., message: String? = nil) -> Validation {
        let commaSeparated = values.map({ String(describing: $0) }).joined(separator: ", ")
        return .init(message ?? "must be one of: \(commaSeparated)") { values.contains($0) }
    }
    
    static func rejecting(_ values: T..., message: String? = nil) -> Validation {
        let commaSeparated = values.map({ String(describing: $0) }).joined(separator: ", ")
        return .init(message ?? "must not be: \(commaSeparated)") { !values.contains($0) }
    }
    
}

public extension Validation where T: Comparable {
    
    static func greaterThan(_ value: T, message: String? = nil) -> Validation {
        return .init(message ?? "must be greater than \(value)") { $0 > value }
    }
    
    static func lessThan(_ value: T, message: String? = nil) -> Validation {
        return .init(message ?? "must be less than \(value)") { $0 < value }
    }
    
    static func within(_ range: ClosedRange<T>, message: String? = nil) -> Validation {
        return .init(message ?? "must be greater than or equal to \(range.lowerBound) and less than or equal to \(range.upperBound)") { range.contains($0) }
    }
    
    static func within(_ range: Range<T>, message: String? = nil) -> Validation {
        return .init(message ?? "must be greater than or equal to \(range.lowerBound) and less than \(range.upperBound)") { range.contains($0) }
    }
    
}

public extension Validation where T == String {
    
    static func contains(_ substring: String, message: String? = nil) -> Validation {
        return .init(message ?? "must contain '\(substring)'") { $0.contains(substring) }
    }
    
}
