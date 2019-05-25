//
//  Compatibility.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/9/17.
//

import Foundation

// MARK: Minor version deprecations

@available(*, deprecated, renamed: "run(_:arguments:)")
public func run(_ executable: String, _ args: [String]) throws {
    try run(executable, arguments: args)
}

@available(*, deprecated, message: "Use run(_:arguments:directory:) instead")
public func run(_ executable: String, directory: String, _ args: String...) throws {
    try run(executable, arguments: args, directory: directory)
}

@available(*, deprecated, message: "Use run(_:arguments:directory:) instead")
public func run(_ executable: String, directory: String, _ args: [String]) throws {
    try run(executable, arguments: args, directory: directory)
}

@available(*, deprecated, renamed: "capture(_:arguments:)")
public func capture(_ executable: String, _ args: [String]) throws -> CaptureResult {
    return try capture(executable, arguments: args)
}

@available(*, deprecated, message: "Use capture(_:arguments:directory:) instead")
public func capture(_ executable: String, directory: String, _ args: String...) throws -> CaptureResult {
    return try capture(executable, arguments: args, directory: directory)
}

@available(*, deprecated, message: "Use capture(_:arguments:directory:) instead")
public func capture(_ executable: String, directory: String?, _ args: [String]) throws -> CaptureResult {
    return try capture(executable, arguments: args, directory: directory)
}

extension Task {
    
    @available(*, deprecated, message: "Use Task.execvp(_:arguments:directory:env) instead")
    public static func execvp(_ executable: String, directory: String? = nil, _ args: String..., env: [String: String]? = nil) throws -> Never {
        try execvp(executable, arguments: args, directory: directory, env: env)
    }
    
    @available(*, deprecated, message: "Use Task.execvp(_:arguments:directory:env) instead")
    public static func execvp(_ executable: String, directory: String? = nil, _ args: [String], env: [String: String]? = nil) throws -> Never {
        try execvp(executable, arguments: args, directory: directory, env: env)
    }
    
    @available(*, deprecated, renamed: "init(executable:arguments:directory:stdout:stderr:stdin:)")
    public convenience init(executable: String, args: [String] = [], currentDirectory: String? = nil, stdout: WritableStream = WriteStream.stdout, stderr: WritableStream = WriteStream.stderr, stdin: ReadableStream = ReadStream.stdin) {
        self.init(executable: executable, arguments: args, directory: currentDirectory, stdout: stdout, stderr: stderr, stdin: stdin)
    }
    
}

public extension Input {
    
    @available(*, unavailable, message: "Use Validation<String>.custom instead of (String) -> Bool")
    static func readLine(prompt: String? = nil, secure: Bool = false, validation: ((String) -> Bool)? = nil, errorResponse: InputReader<String>.ErrorResponse? = nil) -> String {
        return ""
    }
    
    @available(*, unavailable, message: "Use Validation<Int>.custom instead of (String) -> Bool")
    static func readInt(prompt: String? = nil, secure: Bool = false, validation: ((Int) -> Bool)? = nil, errorResponse: InputReader<Int>.ErrorResponse? = nil) -> Int {
        return 0
    }
    
    @available(*, unavailable, message: "Use Validation<Double>.custom instead of (String) -> Bool")
    static func readDouble(prompt: String? = nil, secure: Bool = false, validation: ((Double) -> Bool)? = nil, errorResponse: InputReader<Double>.ErrorResponse? = nil) -> Double {
        return 0
    }
    
    @available(*, unavailable, message: "Use Validation<Bool>.custom instead of (String) -> Bool")
    static func readBool(prompt: String? = nil, secure: Bool = false, validation: ((Bool) -> Bool)? = nil, errorResponse: InputReader<Bool>.ErrorResponse? = nil) -> Bool {
        return false
    }
    
    @available(*, unavailable, message: "Use Validation<T>.custom instead of (T) -> Bool")
    static func readObject<T>(prompt: String? = nil, secure: Bool = false, validation: ((T) -> Bool)? = nil, errorResponse: InputReader<T>.ErrorResponse? = nil) -> T {
        return T.convert(from: "")!
    }
    
}

public extension InputReader {
    @available(*, deprecated, message: "Use Validation<T>.custom instead of InputReader<T>.Validation")
    typealias Validation = (T) -> Bool
}

// MARK: - Swift versions

#if !swift(>=4.1)

extension Sequence {
    func compactMap<T>(_ transform: (Element) -> T?) -> [T] {
        return flatMap(transform)
    }
}

#endif

// MARK: - Linux support

#if os(Linux)
#if swift(>=3.1)
typealias Regex = NSRegularExpression
#else
typealias Regex = RegularExpression
#endif
#else
typealias Regex = NSRegularExpression
#endif

// MARK: Unavailable

extension CLI {
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var name: String { return "" }
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var version: String? { return nil }
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var description: String? { return "" }
    
    @available(*, unavailable, message: "Create a custom HelpMessageGenerator instead")
    public static var helpCommand: Command? = nil
    
    @available(*, unavailable, message: "Create the CLI object with a nil version and register a custom version command")
    public static var versionCommand: Command? = nil
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var helpMessageGenerator: HelpMessageGenerator { return DefaultHelpMessageGenerator() }
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var argumentListManipulators: [ArgumentListManipulator] { return [] }

    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func setup(name: String, version: String? = nil, description: String? = nil) {}
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func register(command: Command) {}
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func register(commands: [Command]) {}
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func go() -> Int32 { return 0 }
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func debugGo(with argumentString: String) -> Int32 { return 0 }
    
    @available(*, unavailable, message: "Use a custom parser instead: cli.parser = Parser(router: MyRouter())")
    public var router: Router {
        get {
            return parser.router
        }
        set(newValue) {
            parser = Parser(router: newValue)
        }
    }
    
    @available(*, unavailable, message: "Use a custom parser instead: cli.parser = Parser(parameterFiller: ParameterFiller())")
    public var parameterFiller: ParameterFiller {
        get {
            return parser.parameterFiller
        }
        set(newValue) {
            parser = Parser(parameterFiller: newValue)
        }
    }
    
}

extension Input {
    
    @available(*, unavailable, message: "Use Input.readLine()")
    public static func awaitInput(message: String?, secure: Bool = false) -> String { return "" }
    
    @available(*, unavailable, message: "Use Input.readLine() with a validation closure")
    public static func awaitInputWithValidation(message: String?, secure: Bool = false, validation: (_ input: String) -> Bool) -> String { return "" }
    
    @available(*, unavailable, message: "Implement CovertibleFromString on a custom object and use Input.readObject()")
    public static func awaitInputWithConversion<T>(message: String?, secure: Bool = false, conversion: (_ input: String) -> T?) -> T { return conversion("")! }
    
    @available(*, unavailable, message: "Use Input.readInt() instead")
    public static func awaitInt(message: String?) -> Int { return 0 }
    
    @available(*, unavailable, message: "Use Input.readBool() instead")
    public static func awaitYesNoInput(message: String = "Confirm?") -> Bool { return false }
    
}

@available(*, unavailable, renamed: "WritableStream")
public typealias OutputByteStream = WritableStream

@available(*, unavailable, message: "Use WriteStream.stdout instead")
public class StdoutStream {}

@available(*, unavailable, message: "Use WriteStream.stderr instead")
public class StderrStream {}

@available(*, unavailable, message: "Use WriteStream.null instead")
public class NullStream {}

@available(*, unavailable, renamed: "WriteStream")
public typealias FileStream = WriteStream

extension WritableStream {
    
    @available(*, unavailable, renamed: "print")
    func output(_ content: String) {}
    
    @available(*, unavailable, renamed: "print")
    public func output(_ content: String, terminator: String) {}
    
}

extension Term {
    @available(*, unavailable, message: "Use WriteStream.stdout instead")
    public static var stdout: WritableStream { return WriteStream.stdout }
    
    @available(*, unavailable, message: "Use WriteStream.stderr instead")
    public static var stderr: WritableStream { return WriteStream.stderr }
}

@available(*, unavailable, message: "use CLI.Error instead")
public enum CLIError: Error {
    case error(String)
    case emptyError
}

@available(*, unavailable, message: "Implement HelpMessageGenerator instead")
public protocol UsageStatementGenerator {
    func generateUsageStatement(for command: Command) -> String
}

@available(*, unavailable, renamed: "WriteStream.stderr.print")
public func printError(_ error: String) {}

@available(*, unavailable, renamed: "WriteStream.stderr.print")
public func printError(_ error: String, terminator: String) {}

extension WriteStream {
    @available(*, unavailable, renamed: "WriteStream.for(path:)")
    public init?(path: String) {
        return nil
    }
    
    @available(*, unavailable, renamed: "WriteStream.for(fileHandle:)")
    public init(writeHandle: FileHandle) {
        fatalError()
    }
    
    @available(*, unavailable, renamed: "closeWrite")
    public func close() {}
}

extension WriteStream.FileStream {
    @available(*, unavailable, renamed: "closeWrite")
    public func close() {}
}

extension WriteStream.FileHandleStream {
    @available(*, unavailable, renamed: "closeWrite")
    public func close() {}
}

extension ReadStream {
    @available(*, unavailable, renamed: "ReadStream.for(path:)")
    public init?(path: String) {
        return nil
    }
    
    @available(*, unavailable, renamed: "ReadStream.for(fileHandle:)")
    public init(readHandle: FileHandle) {
        fatalError()
    }
    
    @available(*, unavailable, renamed: "closeRead")
    public func close() {}
}

extension ReadStream.FileStream {
    @available(*, unavailable, renamed: "closeRead")
    public func close() {}
}

extension ReadStream.FileHandleStream {
    @available(*, unavailable, renamed: "closeRead")
    public func close() {}
}

extension LineStream {
    @available(*, unavailable, message: "no longer needs to be called if this stream is the stdout or stderr of a Task; otherwise call waitToFinishProcessing()")
    public func wait() {}
}
