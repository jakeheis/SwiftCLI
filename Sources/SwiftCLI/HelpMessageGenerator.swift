//
//  HelpMessageGenerator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

public protocol HelpMessageGenerator {
    func writeCommandList(for path: CommandGroupPath, to out: WritableStream)
    func writeUsageStatement(for path: CommandPath, to out: WritableStream)
    func writeRouteErrorMessage(for error: RouteError, to out: WritableStream)
    func writeMisusedOptionsStatement(for error: OptionError, to out: WritableStream)
    func writeParameterErrorMessage(for error: ParameterError, to out: WritableStream)
    func writeUnrecognizedErrorMessage(for error: Error, to out: WritableStream)
}

extension HelpMessageGenerator {
    
    public func writeCommandList(for path: CommandGroupPath, to out: WritableStream) {
        out <<< ""
        out <<< "Usage: \(path.joined()) <command> [options]"
        
        let bottom = path.bottom
        if !bottom.shortDescription.isEmpty {
            out <<< ""
            out <<< bottom.shortDescription
        }
        
        var commandGroups: [CommandGroup] = []
        var commands: [Command] = []
        var maxNameLength = 12
        for routable in bottom.children {
            if let commandGroup = routable as? CommandGroup {
                commandGroups.append(commandGroup)
            } else if let command = routable as? Command {
                commands.append(command)
            }
            if routable.name.count > maxNameLength {
                maxNameLength = routable.name.count
            }
        }
        
        func write(_ routable: Routable) {
            let spacing = String(repeating: " ", count: maxNameLength + 4 - routable.name.count)
            let multilineSpacing = String(repeating: " ", count: maxNameLength + 4 + 2)
            let description = routable.shortDescription.replacingOccurrences(of: "\n", with: "\n\(multilineSpacing)")
            out <<< "  \(routable.name)\(spacing)\(description)"
        }
        
        if !commandGroups.isEmpty {
            out <<< ""
            out <<< "Groups:"
            commandGroups.forEach(write)
        }
        
        if !commands.isEmpty {
            out <<< ""
            out <<< "Commands:"
            commands.forEach(write)
        }
        out <<< ""
    }
    
    public func writeUsageStatement(for path: CommandPath, to out: WritableStream) {
        out <<< ""

        out <<< "Usage: \(path.usage)"

        if !path.command.longDescription.isEmpty {
            out <<< ""
            out <<< path.command.longDescription
        } else if !path.command.shortDescription.isEmpty {
            out <<< ""
            out <<< path.command.shortDescription
        }

        let options = path.options
        if !options.isEmpty {
            out <<< ""
            out <<< "Options:"
            let sortedOptions = options.sorted { (lhs, rhs) in
                return lhs.names.first! < rhs.names.first!
            }
            let maxOptionLength = sortedOptions.reduce(12) { (length, option) in
                if option.identifier.count > length {
                    return option.identifier.count
                }
                return length
            }
            for option in sortedOptions {
                let usage = option.usage(padding: maxOptionLength + 4)
                out <<< "  \(usage)".replacingOccurrences(of: "\n", with: "\n  ")
            }
        }
        out <<< ""
    }
    
    public func writeRouteErrorMessage(for error: RouteError, to out: WritableStream) {
        writeCommandList(for: error.partialPath, to: out)
        if let notFound = error.notFound {
            out <<< "Error: command '\(notFound)' not found"
            out <<< ""
        }
    }
    
    public func writeMisusedOptionsStatement(for error: OptionError, to out: WritableStream) {
        if let command = error.command {
            writeUsageStatement(for: command, to: out)
        } else {
            out <<< ""
        }
        out <<< "Error: " + error.kind.message
        out <<< ""
    }
    
    public func writeParameterErrorMessage(for error: ParameterError, to out: WritableStream) {
        writeUsageStatement(for: error.command, to: out)
        out <<< "Error: " + error.message
        out <<< ""
    }
    
    public func writeUnrecognizedErrorMessage(for error: Error, to out: WritableStream) {
        out <<< "An error occurred: \(error.localizedDescription)"
    }
    
}

public class DefaultHelpMessageGenerator: HelpMessageGenerator {
    public init() {}
}
