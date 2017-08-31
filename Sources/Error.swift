//
//  Error.swift
//  SwiftCLIPackageDescription
//
//  Created by Jake Heiser on 8/30/17.
//

public protocol ProcessError: Swift.Error {
    var message: String? { get }
    var exitStatus: Int32 { get }
    init(message: String?, exitStatus: Int32)
}

extension ProcessError {
    public init() {
        self.init(exitStatus: 1)
    }
    
    public init<T: SignedInteger>(exitStatus: T) {
        self.init(message: nil, exitStatus: Int32(exitStatus))
    }
    
    public init(message: String) {
        self.init(message: message, exitStatus: 1)
    }
    
    public init<T: SignedInteger>(message: String, exitStatus: T) {
        self.init(message: message, exitStatus: Int32(exitStatus))
    }
}

extension CLI {
    
    public struct Error: ProcessError {
        public let message: String?
        public let exitStatus: Int32
        public init(message: String?, exitStatus: Int32) {
            self.message = message
            self.exitStatus = exitStatus
        }
        
    }
    
}

// MARK: -

@available(*, deprecated, message: "use CLI.Error instead")
public enum CLIError: Error {
    case error(String)
    case emptyError
}