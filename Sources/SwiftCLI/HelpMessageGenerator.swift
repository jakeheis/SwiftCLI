//
//  HelpMessageGenerator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

public protocol HelpMessageGenerator {
    func generateCommandList(for path: CommandGroupPath) -> String
    func generateUsageStatement(for path: CommandPath) -> String
    func generateMisusedOptionsStatement(error: OptionError) -> String
}

extension HelpMessageGenerator {
    
    public func generateCommandList(for path: CommandGroupPath) -> String {
        var lines = [
            "",
            "Usage: \(path.joined()) <command> [options]"
        ]
        let bottom = path.bottom
        if !bottom.shortDescription.isEmpty {
            lines += [
                "",
                bottom.shortDescription
            ]
        }
        var commandGroups: [CommandGroup] = []
        var commands: [Command] = []
        var maxNameLength = 12
        for routable in bottom.children {
            if let commandGroup = routable as? CommandGroup { commandGroups.append(commandGroup) }
            if let command = routable as? Command { commands.append(command) }
            if routable.name.count > maxNameLength {
                maxNameLength = routable.name.count
            }
        }
        
        func toLine(_ routable: Routable) -> String {
            let spacing = String(repeating: " ", count: maxNameLength + 4 - routable.name.count)
            return "  \(routable.name)\(spacing)\(routable.shortDescription)"
        }
        
        if !commandGroups.isEmpty {
            lines += [
                "",
                "Groups:"
            ]
            lines += commandGroups.map(toLine)
        }
        
        if !commands.isEmpty {
            lines += [
                "",
                "Commands:"
            ]
            lines += commands.map(toLine)
        }
        
        lines.append("")
        
        return lines.joined(separator: "\n");
    }
    
    public func generateUsageStatement(for path: CommandPath) -> String {
        var message = "\nUsage: \(path.usage)\n"
        
        let options = path.options
        if !options.isEmpty {
            message += "\nOptions:"
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
                message += "\n  \(usage)"
            }
            
            message += "\n"
        }
        
        return message
    }
    
    public func generateMisusedOptionsStatement(error: OptionError) -> String {
        var message = ""
        if let command = error.command {
            message += generateUsageStatement(for: command)
        }
        message += "\n" + error.message + "\n"
        return message
    }
    
}

public class DefaultHelpMessageGenerator: HelpMessageGenerator {
    public init() {}
}

@available(*, unavailable, message: "Implement HelpMessageGenerator instead")
public protocol UsageStatementGenerator {
    func generateUsageStatement(for command: Command) -> String
}

@available(*, unavailable, message: "Implement HelpMessageGenerator instead")
public protocol MisusedOptionsMessageGenerator {
    func generateMisusedOptionsStatement(for command: Command, error: OptionRecognizerError) -> String
}

