//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

// MARK: - Routables

public protocol Routable: class {
    var name: String { get }
    var shortDescription: String { get }
}

extension Routable {
    public var stdout: WriteStream {
        return WriteStream.stdout
    }
    
    public var stderr: WriteStream {
        return WriteStream.stderr
    }
}

// MARK: -

public protocol Command: Routable {
    
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
    var options: [Option] { get }
    
}

@available(*, unavailable, renamed: "Command")
public typealias OptionCommand = Command

extension Command {
    
    // Defaults
    
    public var parameters: [(String, AnyParameter)] {
        return parametersFromMirror(Mirror(reflecting: self))
    }
    
    public var options: [Option] {
        return optionsFromMirror(Mirror(reflecting: self))
    }
    
    func parametersFromMirror(_ mirror: Mirror) -> [(String, AnyParameter)] {
        var parameters: [(String, AnyParameter)] = []
        if let superMirror = mirror.superclassMirror {
            parameters = parametersFromMirror(superMirror)
        }
        parameters.append(contentsOf: mirror.children.optMap { (child) in
            if let argument = child.value as? AnyParameter, let label = child.label {
                return (label, argument)
            }
            return nil
        })
        return parameters
    }
    
    func optionsFromMirror(_ mirror: Mirror) -> [Option] {
        var options: [Option] = []
        if let superMirror = mirror.superclassMirror {
            options = optionsFromMirror(superMirror)
        }
        options.append(contentsOf: mirror.children.optMap { (child) -> Option? in
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

}

// MARK: -

public protocol CommandGroup: Routable {
    var children: [Routable] { get }
    var sharedOptions: [Option] { get }
    var aliases: [String: String] { get }
}

public extension CommandGroup {
    var sharedOptions: [Option] {
        return []
    }
    var aliases: [String: String] {
        return [:]
    }
}

