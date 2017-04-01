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
    
    /// The paramters this command accepts; dervied automatically, don't implement unless custom functionality needed
    var parameters: [(String, AnyParameter)] { get }
    
    /// The options this command accepts; dervied automatically, don't implement unless custom functionality needed
    var options: [Option] { get }
    
    /// A short description of the command; printed in the command's usage statement; defaults to empty string
    var shortDescription: String { get }
    
    /// The option groups of this command; defaults to empty array
    var optionGroups: [OptionGroup] { get }
    
}

@available(*, unavailable, renamed: "Command")
public typealias OptionCommand = Command

extension Command {
    
    // Defaults
    
    public var parameters: [(String, AnyParameter)] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.flatMap { (child) in
            if let argument = child.value as? AnyParameter, let label = child.label {
                return (label, argument)
            }
            return nil
        }
    }

    public var options: [Option] {
        let mirror = Mirror(reflecting: self)
        var options = mirror.children.flatMap { (child) -> Option? in
            if let option = child.value as? Option {
                return option
            }
            return nil
        }
        options += GlobalOptions.options
        return options
    }
    
    public var shortDescription: String {
        return ""
    }
    
    public var optionGroups: [OptionGroup] {
        return []
    }
    
    // Extras
    
    public var signature: String {
        return parameters.map({ $0.1.signature(for: $0.0) }).joined(separator: " ")
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
