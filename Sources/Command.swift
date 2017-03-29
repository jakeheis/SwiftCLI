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

    /// The name of the command; used to route arguments to commands
    var name: String { get }

    /// A short description of the command; printed in the command's usage statement
    var shortDescription: String { get }
    
    /// The arguments this command accepts - dervied automatically, don't implement
    var arguments: [(String, AnyArgument)] { get }
    
    /// The options this command accepts - dervied automatically, don't implement
    var options: [(String, Option)] { get }
    
    /// The help flag for this command; defaults to -h
    var helpFlag: Flag? { get }
    
    var optionGroups: [OptionGroup] { get }
    
    /**
        The actual execution block of the command

        - Parameter arguments: the parsed arguments
    */
    func execute() throws

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
