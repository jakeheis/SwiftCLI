//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

// MARK: Protocols

/// The base protocol for all commands
public protocol Command: class {
    
    //
    // Required:
    //

    /// The name of the command; used to route arguments to commands
    var name: String { get }
    
    /// Executes the command
    ///
    /// - Throws: CLIError if command cannot execute successfully
    func execute() throws

    //
    // Optional:
    //
    
    /// The arguments this command accepts; dervied automatically, don't implement unless custom functionality needed
    var arguments: [(String, AnyArgument)] { get }
    
    /// The options this command accepts; dervied automatically, don't implement unless custom functionality needed
    var options: [(String, Option)] { get }
    
    /// A short description of the command; printed in the command's usage statement; defaults to empty string
    var shortDescription: String { get }
    
    /// The help flag for this command; defaults to Flag("-h")
    var helpFlag: Flag? { get }
    
    /// The option groups of this command; defaults to empty array
    var optionGroups: [OptionGroup] { get }
    
}

extension Command {
    
    // Defaults
    
    public var arguments: [(String, AnyArgument)] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.flatMap { (child) in
            if let argument = child.value as? AnyArgument, let label = child.label {
                return (label, argument)
            }
            return nil
        }
    }

    public var options: [(String, Option)] {
        let mirror = Mirror(reflecting: self)
        var options = mirror.children.flatMap { (child) -> (String, Option)? in
            if let option = child.value as? Option, let label = child.label {
                return (label, option)
            }
            return nil
        }
        if let helpFlag = helpFlag {
            options.append(("helpFlag", helpFlag))
        }
        return options
    }
    
    var shortDescription: String {
        return ""
    }
    
    public var helpFlag: Flag? {
        return Flag("-h", "--help", usage: "Show help information for this command")
    }
    
    public var optionGroups: [OptionGroup] {
        return []
    }
    
    // Extras
    
    public var signature: String {
        return arguments.map({ $0.1.signature(for: $0.0) }).joined(separator: " ")
    }

    public var usage: String {
        var message = "Usage: \(CLI.name)"

        if !name.isEmpty {
            message += " \(name)"
        }

        if !signature.isEmpty {
            message += " \(signature)"
        }

        return message
    }

}
