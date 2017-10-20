//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

// MARK: - Routables

public protocol Routable {
    var name: String { get }
    var shortDescription: String { get }
}


// MARK: -

public protocol Command: class, Routable {
    
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
    
    /// A short description of the command; printed in the command's usage statement; defaults to empty string
    var shortDescription: String { get }
    
    /// The option groups of this command; defaults to empty array
    var optionGroups: [OptionGroup] { get }
    
    /// The options this command accepts; dervied automatically, don't implement unless custom functionality needed
    func options(for cli: CLI) -> [Option]
    
}

@available(*, unavailable, renamed: "Command")
public typealias OptionCommand = Command

extension Command {
    
    // Defaults
    
    public var parameters: [(String, AnyParameter)] {
        return parametersFromMirror(Mirror(reflecting: self))
    }
    
    func parametersFromMirror(_ mirror: Mirror) -> [(String, AnyParameter)] {
        var parameters: [(String, AnyParameter)] = []
        if let superMirror = mirror.superclassMirror {
            parameters = parametersFromMirror(superMirror)
        }
        parameters.append(contentsOf: mirror.children.flatMap { (child) in
            if let argument = child.value as? AnyParameter, let label = child.label {
                return (label, argument)
            }
            return nil
        })
        return parameters
    }

    public func options(for cli: CLI) -> [Option] {
        var options = optionsFromMirror(Mirror(reflecting: self))
        options += cli.globalOptions
        return options
    }
    
    func optionsFromMirror(_ mirror: Mirror) -> [Option] {
        var options: [Option] = []
        if let superMirror = mirror.superclassMirror {
            options = optionsFromMirror(superMirror)
        }
        options.append(contentsOf: mirror.children.flatMap { (child) -> Option? in
            if let option = child.value as? Option {
                return option
            }
            return nil
        })
        return options
    }
    
    public var shortDescription: String {
        return ""
    }
    
    public var optionGroups: [OptionGroup] {
        return []
    }
    
    // Extras
    
    public func usage(for cli: CLI) -> String {
        var message = ""

        if !name.isEmpty {
            message += "\(name)"
        }

        if !parameters.isEmpty {
            let signature = parameters.map({ $0.1.signature(for: $0.0) }).joined(separator: " ")
            message += " \(signature)"
        }
        
        if !options(for: cli).isEmpty {
            message += " [options]"
        }

        return message
    }
    
    public var stdout: OutputByteStream {
        return Term.stdout
    }
    
    public var stderr: OutputByteStream {
        return Term.stderr
    }

}

// MARK: -

public protocol CommandGroup: Routable {
    var children: [Routable] { get }
}

