//
//  CLI-deprecated.swift
//  SwiftCLIPackageDescription
//
//  Created by Jake Heiser on 9/9/17.
//

extension CLI {
 
    private static var shared: CLI?
    
    private static func guardShared() -> CLI {
        guard let cli = shared else {
            fatalError("Call CLI.setup() before making other calls")
        }
        return cli
    }
    
    // MARK: - Information
    
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static var name: String {
        get {
            return guardShared().name
        }
    }
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static var version: String? {
        get {
            return guardShared().version
        }
    }
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
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
    
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static var helpMessageGenerator: HelpMessageGenerator {
        get {
            return guardShared().helpMessageGenerator
        }
        set(newValue) {
            guardShared().helpMessageGenerator = newValue
        }
    }
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static var argumentListManipulators: [ArgumentListManipulator] {
        get {
            return guardShared().argumentListManipulators
        }
        set(newValue) {
            guardShared().argumentListManipulators = newValue
        }
    }
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static var router: Router {
        get {
            return guardShared().router
        }
        set(newValue) {
            guardShared().router = newValue
        }
    }
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static var optionRecognizer: OptionRecognizer {
        get {
            return guardShared().optionRecognizer
        }
        set(newValue) {
            guardShared().optionRecognizer = newValue
        }
    }
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static var parameterFiller: ParameterFiller {
        get {
            return guardShared().parameterFiller
        }
        set(newValue) {
            guardShared().parameterFiller = newValue
        }
    }
    
    // MARK: - Setup
    
    /// Sets the CLI up with basic information
    ///
    /// - Parameters:
    ///   - name: name of the app, printed in the help message and command usage statements
    ///   - version: version of the app, printed by the VersionCommand
    ///   - description: description of the app, printed in the help message
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static func setup(name: String, version: String? = nil, description: String? = nil) {
        guard shared == nil else {
            fatalError("Cannot call CLI.setup() multiple times")
        }
        
        shared = CLI(name: name, commands: [], version: version)
        shared?.description = description
    }
    
    /// Registers a command with the CLI for routing and execution. All commands must be registered
    /// with this method or its siblings before calling `CLI.go()`
    ///
    /// - Parameter command: the command to be registered
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static func register(command: Command) {
        guardShared().commands.append(command)
    }
    
    /// Registers a group of commands with the CLI for routing and execution. All commands must be registered
    /// with this method or its siblings before calling `CLI.go()`
    ///
    /// - Parameter commands: the commands to be registered
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static func register(commands: [Command]) {
        commands.forEach { self.register(command: $0) }
    }
    
    /// Registers a chainable command with the CLI for routing and execution.
    ///
    /// - Parameter name: the name of the new chainable command
    /// - Returns: a new chainable command for immediate chaining
    @available(*, deprecated, message: "add a custom type implementing Command to the CLI.commands array")
    public static func registerChainableCommand(name: String) -> ChainableCommand {
        let chainable = ChainableCommand(name: name)
        register(command: chainable)
        return chainable
    }
    
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static func go() -> Int32 {
        return guardShared().go()
    }
    
    @available(*, deprecated, message: "Create a new CLI object: let cli = CLI(..)")
    public static func debugGo(with argumentString: String) -> Int32 {
        return guardShared().debugGo(with: argumentString)
    }
    
}
