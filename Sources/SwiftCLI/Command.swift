//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

// MARK: - Routables

public protocol Routable: class {
    /// The name of the command or command group
    var name: String { get }
    
    /// A concise description of what this command or group is
    var shortDescription: String { get }
    
    /// A longer description of how to use this command or group
    var longDescription: String { get }
    
    /// The options this command accepts; dervied automatically, don't implement unless custom functionality needed
    var options: [Option] { get }
    
    /// The option groups of this command; defaults to empty array
    var optionGroups: [OptionGroup] { get }
}

extension Routable {
    
    /// Standard out stream
    public var stdout: WritableStream {
        return WriteStream.stdout
    }
    
    /// Standard error stream
    public var stderr: WritableStream {
        return WriteStream.stderr
    }
    
    public var options: [Option] {
        return optionsFromMirror(Mirror(reflecting: self))
    }
    
    private func optionsFromMirror(_ mirror: Mirror) -> [Option] {
        var options: [Option] = []
        if let superMirror = mirror.superclassMirror {
            options = optionsFromMirror(superMirror)
        }
        options.append(contentsOf: mirror.children.compactMap { (child) -> Option? in
            _ = [child.label][0] // Linux 4.2 crashes for some reason if this isn't done
            if (child.label != "children" && child.label != "optionGroups"), let option = child.value as? Option {
                return option
            }
            return nil
        })
        return options
    }
    
    public var optionGroups: [OptionGroup] {
        return []
    }
}

// MARK: -

public protocol Command: Routable {
    
    /// Executes the command
    ///
    /// - Throws: CLI.Error if command cannot execute successfully
    func execute() throws
    
    /// The paramters this command accepts; derived automatically, don't implement unless custom functionality needed
    var parameters: [(String, AnyParameter)] { get }
    
}

extension Command {
    
    public var parameters: [(String, AnyParameter)] {
        return parametersFromMirror(Mirror(reflecting: self))
    }
    
    private func parametersFromMirror(_ mirror: Mirror) -> [(String, AnyParameter)] {
        var parameters: [(String, AnyParameter)] = []
        if let superMirror = mirror.superclassMirror {
            parameters = parametersFromMirror(superMirror)
        }
        parameters.append(contentsOf: mirror.children.compactMap { (child) in
            _ = [child.label][0] // Linux 4.2 crashes for some reason if this isn't done
            if (child.label != "children" && child.label != "optionGroups"), let param = child.value as? AnyParameter, let label = child.label {
                return (label, param)
            }
            return nil
        })
        return parameters
    }
    
    public var shortDescription: String {
        return ""
    }
    
    public var longDescription: String {
        return ""
    }
    
}

// MARK: -

public protocol CommandGroup: Routable {
    /// The sub-commands and sub-groups of this group
    var children: [Routable] { get }
    
    /// Aliases for chlidren, e.g. "--help" for "help"; default empty dictionary
    var aliases: [String: String] { get }
}

public extension CommandGroup {
    var aliases: [String: String] {
        return [:]
    }
    
    var longDescription: String {
        return ""
    }
}
