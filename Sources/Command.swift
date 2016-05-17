//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

// MARK: Protocols

/// The base protocol for all commands
public protocol CommandType {

    /// The name of the command; used to route arguments to commands
    var commandName: String { get }
    
    // The argument signature of the command; used to map RawArguments to CommandArguments
    /// See the README for details on this
    var commandSignature: String { get }
    
    /// A short description of the command; printed in the command's usage statement
    var commandShortDescription: String { get }
    
    /// An optional flag shorcut for the command; e.g. "-h" for the HelpCommand. Default's to nil.
    var commandShortcut: String? { get }
    
    /**
        The actual execution block of the command
    
        - Parameter arguments: the parsed arguments
    */
    func execute(arguments: CommandArguments) throws
    
}

/// An expansion of CommandType to provide for option handling
public protocol OptionCommandType: CommandType {
    
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
    func setupOptions(options: Options)

}

// MARK: Default implementations

extension CommandType {
    
    public var commandShortcut: String? { return nil }
    
}

extension OptionCommandType {
    
    public var failOnUnrecognizedOptions: Bool { return true }
    
    public var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior { return .PrintAll }
    
    public var helpOnHFlag: Bool { return true }
    
}

// MARK: Additional functionality

extension OptionCommandType {
    
    func internalSetupOptions(options: Options) {
        setupOptions(options: options)
        
        if helpOnHFlag {
            let helpFlags = ["-h", "--help"]
            
            options.onFlags(flags: helpFlags, usage: "Show help information for this command") {(flag) in
                print(CommandMessageGenerator.generateUsageStatement(command: self, options: options))
            }

            options.exitEarlyOptions += helpFlags
        }
    }
    
}

// MARK: Enums

public enum UnrecognizedOptionsPrintingBehavior {
    case PrintNone
    case PrintOnlyUnrecognizedOptions
    case PrintOnlyUsage
    case PrintAll
}
