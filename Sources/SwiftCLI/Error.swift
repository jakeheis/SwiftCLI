//
//  Error.swift
//  SwiftCLIPackageDescription
//
//  Created by Jake Heiser on 8/30/17.
//

public protocol ProcessError: Swift.Error {
    var message: String? { get }
    var exitStatus: Int32 { get }
}

extension CLI {
    
    public struct Error: ProcessError {
        
        public let message: String?
        public let exitStatus: Int32
        
        public init() {
            self.init(exitStatus: 1)
        }
        
        #if swift(>=4.0)
        public init<T: BinaryInteger>(exitStatus: T) {
            self.init(message: nil, exitStatus: Int32(exitStatus))
        }
        #else
        public init(exitStatus: Int) {
            self.init(message: nil, exitStatus: Int32(exitStatus))
        }
        public init(exitStatus: Int32) {
            self.init(message: nil, exitStatus: exitStatus)
        }
        #endif

        public init(message: String) {
            self.init(message: message, exitStatus: 1)
        }
        
        public init(message: String?, exitStatus: Int32) {
            self.message = message
            self.exitStatus = exitStatus
        }
        
    }
    
}

// MARK: - Parse errors

public struct RouteError: Swift.Error {
    public let partialPath: CommandGroupPath
    public let notFound: String?
    
    public init(partialPath: CommandGroupPath, notFound: String?) {
        self.partialPath = partialPath
        self.notFound = notFound
    }
}

public struct OptionError: Swift.Error {
    
    public enum Kind {
        case expectedValueAfterKey(String)
        case illegalTypeForKey(String, Any.Type)
        case unrecognizedOption(String)
        case optionGroupMisuse(OptionGroup)
        case validationError(String, String)
        
        public var message: String {
            switch self {
            case let .expectedValueAfterKey(key):
                return "expected a value to follow '\(key)'"
            case let .illegalTypeForKey(key, type):
                return "illegal value passed to '\(key)' (expected \(type))"
            case let .unrecognizedOption(opt):
                return "unrecognized option '\(opt)'"
            case let .optionGroupMisuse(group):
                let condition: String
                if group.options.count == 1 {
                    condition = "must pass the following option"
                } else {
                    switch group.restriction {
                    case .exactlyOne:
                        condition = "must pass exactly one of the following"
                    case .atLeastOne:
                        condition = "must pass at least one of the following"
                    case .atMostOne:
                        condition = "must not pass more than one of the following"
                    }
                }
                return condition + ": \(group.options.compactMap({ $0.names.last }).joined(separator: " "))"
            case let .validationError(key, message):
                return "illegal value passed to '\(key)': \(message)"
            }
        }
    }
    
    public let command: CommandPath?
    public let kind: Kind
    
    public init(command: CommandPath?, kind: Kind) {
        self.command = command
        self.kind = kind
    }
}

public struct ParameterError: Swift.Error {
    
    public enum Kind {
        case wrongNumber(ParameterIterator)
        case illegalTypeForParameter(String, AnyParameter)
        
        public var message: String {
            switch self {
            case let .wrongNumber(iterator):
                let plural = iterator.minCount == 1 ? "argument" : "arguments"
                switch iterator.maxCount {
                case .none:
                    return "command requires at least \(iterator.minCount) \(plural)"
                case let .some(max) where max == iterator.minCount:
                    return "command requires exactly \(max) \(plural)"
                case let .some(max):
                    return "command requires between \(iterator.minCount) and \(max) arguments"
                }
            case let .illegalTypeForParameter(paramName, param):
                if let paramValue = param.paramType as? CustomParameterValue.Type {
                    return paramValue.errorMessage(paramName: paramName, parameter: param)
                }
                return "illegal value passed to '\(paramName)' (expected \(param.paramType))"
            }
        }
    }
    
    public let command: CommandPath
    public let kind: Kind
    
    public init(command: CommandPath, kind: Kind) {
        self.command = command
        self.kind = kind
    }
}
