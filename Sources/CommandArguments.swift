//
//  CommandArguments.swift
//  Example
//
//  Created by Jake Heiser on 3/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

/*public class CommandArguments {

    let keyedArguments: [String: Any]

    init() {
        keyedArguments = [:]
    }

    init(rawArguments: RawArguments, signature: CommandSignature) throws {
//        keyedArguments = try CLI.commandArgumentParser.parse(rawArguments: rawArguments, with: signature)
    }

    // MARK: - Subscripting

    /**
        Generic subscripting of arguments

        - SeeAlso: Typesafe shortcuts such as `args.requiredArguments("arg")`
    */
    public subscript(key: String) -> Any? {
        get {
            return keyedArguments[key]
        }
    }

    // MARK: - Typesafe shortcuts

    /**
        Subscripting shortcut for arguments guaranteed to be present. Only use for arguments
        in the command signature of the form `<requiredArgument>`

        - Parameter key: the name of the argument as seen in the command signature
    */
    public func requiredArgument(_ key: String) -> String {
        return optionalArgument(key)!
    }

    /**
        Subscripting shortcut for arguments sometimes present. Only use for arguments
        in the command signature of the form `[<optionalArgument>]`

        - Parameter key: the name of the argument as seen in the command signature
    */
    public func optionalArgument(_ key: String) -> String? {
        if let arg = keyedArguments[key] as? String {
            return arg
        }
        return nil
    }

    /**
        Subscripting shortcut for a collected argument guaranteed to be present. Only use
        for arguments in the command signature of the form `<requiredArgument> ...`

        - Parameter key: the name of the argument as seen in the command signature
    */
    public func requiredCollectedArgument(_ key: String) -> [String] {
        return optionalCollectedArgument(key)!
    }

    /**
        Subscripting shortcut for a collected argument sometimes present. Only use
        for arguments in the command signature of the form `[<optionalArgument>] ...`

        - Parameter key: the name of the argument as seen in the command signature
    */
    public func optionalCollectedArgument(_ key: String) -> [String]? {
        if let arg = keyedArguments[key] as? [String] {
            return arg
        }
        return nil
    }

}*/

public protocol Arg {
    var required: Bool { get }
    var collected: Bool { get }
    
    func signature(for name: String) -> String
}

public class Argument: Arg {
    
    public let required = true
    public let collected = false
    private var privateValue: String? = nil
    
    public var value: String {
        return privateValue!
    }

    public init() {}
    
    public func update(value: String) {
        privateValue = value
    }
    
    public func signature(for name: String) -> String {
        return "[\(name)]"
    }

}

public class OptionalArgument: Arg {
    
    public let required = false
    public let collected = false
    public var value: String? = nil
    
    public init() {}
    
    public func update(value: String) {
        self.value = value
    }
    
    public func signature(for name: String) -> String {
        return "<[\(name)]>"
    }
    
}

public class CollectedArgument: Arg {
    
    public let required = true
    public let collected = true
    public var value: [String] = []
    
    public init() {}
    
    public func update(value: [String]) {
        self.value = value
    }
    
    public func signature(for name: String) -> String {
        return "[\(name)] ..."
    }

}

public class OptionalCollectedArgument: Arg {
    
    public let required = false
    public let collected = true
    public var value: [String]? = nil
    
    public init() {}
    
    public func update(value: [String]) {
        self.value = value
    }
    
    public func signature(for name: String) -> String {
        return "<[\(name)]> ..."
    }
    
}

/*class MyCommand: OptionCommand {

    let name = "cmd"
    let signature = "<sig>"
    var shortDescription: String = "Yeh"

    let greeting = StringArgument()
    let person = StringArgument()
    let arguments: [AnyArgument]

    enum Verbosity: Int {
        case error = -2
        case none = -1
        case silent = 1
        case errors = 2
        case some = 3
        case most = 4
        case informative = 5
    }

    var verbosity: Verbosity = .none

    init() {
        arguments = [greeting, person]
    }

    public func setupOptions(options: OptionRegistry) {
        options.add(flags: ["-s", "--silently"]) {
            self.updateVerbosity(.silent)
        }
        options.add(flags: ["-informative", "--informative"]) {
            self.updateVerbosity(.informative)
        }
        options.add(keys: ["-v", "--verbosity"], usage: "Sets the verbosity level to <value>") { (value) in
            self.updateVerbosity(Verbosity(rawValue: Int(value) ?? -1) ?? .none)
        }
    }

    func updateVerbosity(_ val: Verbosity) {
        verbosity = (verbosity == .none ? val : .error)
    }

    public func execute(arguments: CommandArguments) throws  {
        if verbosity == .none || verbosity == .error {
            throw CLIError.error("Error")
        }
    }

}*/
