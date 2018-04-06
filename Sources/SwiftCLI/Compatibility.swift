//
//  Compatibility.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/9/17.
//

import Foundation

extension CLI {
    
    static var shared: CLI?
    
    private static func guardShared() -> CLI {
        guard let cli = shared else {
            fatalError("Call CLI.setup() before making other calls")
        }
        return cli
    }
    
    // MARK: - Information
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var name: String {
        get {
            return guardShared().name
        }
    }
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var version: String? {
        get {
            return guardShared().version
        }
    }
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var description: String? {
        get {
            return guardShared().description
        }
        set(newValue) {
            guardShared().description = newValue
        }
    }
    @available(*, unavailable, message: "Create a custom HelpMessageGenerator instead")
    public static var helpCommand: Command? = nil
    
    @available(*, unavailable, message: "Create the CLI object with a nil version and register a custom version command")
    public static var versionCommand: Command? = nil
    
    // MARK: - Advanced customization
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var helpMessageGenerator: HelpMessageGenerator {
        get {
            return guardShared().helpMessageGenerator
        }
        set(newValue) {
            guardShared().helpMessageGenerator = newValue
        }
    }
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static var argumentListManipulators: [ArgumentListManipulator] {
        get {
            return guardShared().argumentListManipulators
        }
        set(newValue) {
            guardShared().argumentListManipulators = newValue
        }
    }
    
    // MARK: - Setup
    
    /// Sets the CLI up with basic information
    ///
    /// - Parameters:
    ///   - name: name of the app, printed in the help message and command usage statements
    ///   - version: version of the app, printed by the VersionCommand
    ///   - description: description of the app, printed in the help message
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func setup(name: String, version: String? = nil, description: String? = nil) {}
    
    /// Registers a command with the CLI for routing and execution. All commands must be registered
    /// with this method or its siblings before calling `CLI.go()`
    ///
    /// - Parameter command: the command to be registered
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func register(command: Command) {}
    
    /// Registers a group of commands with the CLI for routing and execution. All commands must be registered
    /// with this method or its siblings before calling `CLI.go()`
    ///
    /// - Parameter commands: the commands to be registered
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func register(commands: [Command]) {}
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func go() -> Int32 {
        return guardShared().go()
    }
    
    @available(*, unavailable, message: "Create a new CLI object: let cli = CLI(..)")
    public static func debugGo(with argumentString: String) -> Int32 {
        return guardShared().debugGo(with: argumentString)
    }
    
}

extension Input {
    
    @available(*, deprecated, message: "Use Input.readLine()")
    public static func awaitInput(message: String?, secure: Bool = false) -> String {
        var input: String? = nil
        while input == nil {
            if let message = message {
                var printMessage = message
                if !printMessage.hasSuffix(" ") && !printMessage.hasSuffix("\n") {
                    printMessage += " "
                }
                print(printMessage, terminator: "")
                fflush(stdout)
            }
            
            if secure {
                if let chars = UnsafePointer<CChar>(getpass("")) {
                    input = String(cString: chars, encoding: .utf8)
                }
            } else {
                input = readLine()
            }
        }
        
        return input!
    }
    
    @available(*, deprecated, message: "Use Input.readLine() with a validation closure")
    public static func awaitInputWithValidation(message: String?, secure: Bool = false, validation: (_ input: String) -> Bool) -> String {
        while true {
            let str = awaitInput(message: message, secure: secure)
            
            if validation(str) {
                return str
            } else {
                print("Invalid input")
            }
        }
    }
    
    @available(*, deprecated, message: "Implement CovertibleFromString on a custom object and use Input.readObject()")
    public static func awaitInputWithConversion<T>(message: String?, secure: Bool = false, conversion: (_ input: String) -> T?) -> T {
        let input = awaitInputWithValidation(message: message) { (input) in
            return conversion(input) != nil
        }
        
        return conversion(input)!
    }
    
    @available(*, deprecated, message: "Use Input.readInt() instead")
    public static func awaitInt(message: String?) -> Int {
        return awaitInputWithConversion(message: message) { Int($0) }
    }
    
    @available(*, deprecated, message: "Use Input.readBool() instead")
    public static func awaitYesNoInput(message: String = "Confirm?") -> Bool {
        return awaitInputWithConversion(message: "\(message) [y/N]: ") {(input) in
            if input.lowercased() == "y" || input.lowercased() == "yes" {
                return true
            } else if input.lowercased() == "n" || input.lowercased() == "no" {
                return false
            }
            
            return nil
        }
    }
    
}

@available(*, unavailable, message: "Use myCLI.aliases instead")
public class CommandAliaser: ArgumentListManipulator {
    public func manipulate(arguments: ArgumentList) {}
}

extension Sequence {
    func optMap<T>(_ transform: (Element) -> T?) -> [T] {
        #if swift(>=4.1)
        return compactMap(transform)
        #else
        return flatMap(transform)
        #endif
    }
}

// MARK: - Streams

@available(*, deprecated, renamed: "WritableStream")
public typealias OutputByteStream = WritableStream

@available(*, deprecated, message: "Use WriteStream.stdout instead")
public class StdoutStream: WriteStream {
    convenience init() {
        self.init(writeHandle: FileHandle.standardOutput)
    }
}


@available(*, deprecated, message: "Use WriteStream.stderr instead")
public class StderrStream: WriteStream {
    convenience init() {
        self.init(writeHandle: FileHandle.standardError)
    }
}

@available(*, deprecated, message: "Use WriteStream.null instead")
public class NullStream: WriteStream {
    convenience init() {
        self.init(writeHandle: FileHandle.nullDevice)
    }
}

@available(*, deprecated, renamed: "WriteStream")
public typealias FileStream = WriteStream

extension WritableStream {
    
    @available(*, deprecated, renamed: "print")
    func output(_ content: String) {
        output(content, terminator: "\n")
    }
    
    @available(*, deprecated, renamed: "print")
    public func output(_ content: String, terminator: String) {
        print(content, terminator: terminator)
    }
    
}

extension Term {
    @available(*, deprecated, message: "Use WriteStream.stdout instead")
    public static var stdout: WriteStream {
        return WriteStream.stdout
    }
    
    @available(*, deprecated, message: "Use WriteStream.stderr instead")
    public static var stderr: WriteStream {
        return WriteStream.stderr
    }
}
