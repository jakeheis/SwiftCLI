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
        
        public init<T: BinaryInteger>(exitStatus: T) {
            self.init(message: nil, exitStatus: Int32(exitStatus))
        }

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
        case unrecognizedOption(String)
        case optionGroupMisuse(OptionGroup)
        case invalidKeyValue(AnyKey, String, InvalidValueReason)
        
        public var message: String {
            switch self {
            case let .expectedValueAfterKey(key):
                return "expected a value to follow '\(key)'"
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
            case let .invalidKeyValue(key, id, reason):
                return key.valueType.messageForInvalidValue(reason: reason, for: id)
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
        case wrongNumber(Int, Int?)
        case invalidValue(NamedParameter, InvalidValueReason)
        
        public var message: String {
            switch self {
            case let .wrongNumber(min, max):
                let plural = min == 1 ? "argument" : "arguments"
                switch max {
                case .none:
                    return "command requires at least \(min) \(plural)"
                case let .some(max) where max == min:
                    return "command requires exactly \(max) \(plural)"
                case let .some(max):
                    return "command requires between \(min) and \(max) arguments"
                }
            case let .invalidValue(param, reason):
                return param.param.valueType.messageForInvalidValue(reason: reason, for: param.name)
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
