//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

// MARK: Protocols

/// The base protocol for all commands
public protocol Command {

    /// The name of the command; used to route arguments to commands
    var name: String { get }
    
    // The argument signature of the command; used to map RawArguments to CommandArguments
    /// See the README for details on this
    var signature: String { get }
    
    /// A short description of the command; printed in the command's usage statement
    var shortDescription: String { get }
    
    /// An optional flag shorcut for the command; e.g. "-h" for the HelpCommand. Default's to nil.
    var shortcut: String? { get }
    
    /**
        The actual execution block of the command
    
        - Parameter arguments: the parsed arguments
    */
    func execute(arguments: CommandArguments) throws
    
}

/// An expansion of CommandType to provide for option handling
public protocol OptionCommand: Command {
    
    /// Whether the command should fail if passed unrecognized options. Default is true.
    var failOnUnrecognizedOptions: Bool { get }
    
    /// The output behavior of the command when passed unrecognized options. Default is .PrintAll
    var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior { get }
    
    /// Whether help for the command should be shown when -h is passed. Default is true.
    var helpOnHFlag: Bool { get }
    
    /**
        Where the command should configure all possible Options for the command
    
        - Parameter options: the instance of Options which should be set up
    */
    func setupOptions(options: OptionRegistry)

}

// MARK: Default implementations

extension Command {
    
    public var shortcut: String? { return nil }
    
}

extension OptionCommand {
    
    public var failOnUnrecognizedOptions: Bool { return true }
    
    public var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior { return .printAll }
    
    public var helpOnHFlag: Bool { return true }
    
}

// MARK: Additional functionality

extension OptionCommand {
    
    func internalSetupOptions(options: OptionRegistry) {
        setupOptions(options: options)
        
        if helpOnHFlag {
            let helpFlags = ["-h", "--help"]
            
            options.add(flags: helpFlags, usage: "Show help information for this command") {(flag) in
                print(CLI.usageStatementGenerator.generateUsageStatement(for: self, optionRegistry: options))
            }

            options.exitEarlyOptions += helpFlags
        }
    }
    
}

// MARK: Enums

public enum UnrecognizedOptionsPrintingBehavior {
    case printNone
    case printOnlyUnrecognizedOptions
    case printOnlyUsage
    case printAll
}
