//
//  Compatibility.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/9/17.
//

import Foundation

// MARK: - Swift versions

extension Sequence {
    func optMap<T>(_ transform: (Element) -> T?) -> [T] {
        #if swift(>=4.1)
        return compactMap(transform)
        #else
        return flatMap(transform)
        #endif
    }
}

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
public class StdoutStream: WriteStream {}

@available(*, unavailable, message: "Use WriteStream.stderr instead")
public class StderrStream: WriteStream {}

@available(*, unavailable, message: "Use WriteStream.null instead")
public class NullStream: WriteStream {}

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
    public static var stdout: WriteStream { return WriteStream.stdout }
    
    @available(*, unavailable, message: "Use WriteStream.stderr instead")
    public static var stderr: WriteStream { return WriteStream.stderr }
}

@available(*, unavailable, message: "use CLI.Error instead")
public enum CLIError: Error {
    case error(String)
    case emptyError
}
