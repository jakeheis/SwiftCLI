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

// MARK: -

public struct RouteError: Swift.Error {
    public let partialPath: CommandGroupPath
    public let notFound: String?
    
    public init(partialPath: CommandGroupPath, notFound: String?) {
        self.partialPath = partialPath
        self.notFound = notFound
    }
}

public struct OptionError: Swift.Error {
    let command: CommandPath?
    let message: String
    
    public init(command: CommandPath?, message: String) {
        self.command = command
        self.message = message
    }
}

public struct ParameterError: Swift.Error {
    let command: CommandPath
    let message: String
    
    public init(command: CommandPath, message: String) {
        self.command = command
        self.message = message
    }
}

// MARK: -

@available(*, unavailable, message: "use CLI.Error instead")
public enum CLIError: Error {
    case error(String)
    case emptyError
}
