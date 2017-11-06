//
//  HelpMessageGenerator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

public protocol HelpMessageGenerator {
    func generateCommandList(prefix: String, description: String?, routables: [Routable]) -> String
    func generateUsageStatement(for command: Command, in cli: CLI) -> String
    func generateMisusedOptionsStatement(for command: Command, error: OptionRecognizerError, in cli: CLI) -> String
}

extension HelpMessageGenerator {
    
    public func generateCommandList(prefix: String, description: String?, routables: [Routable]) -> String {
        var lines = [
            "",
            "Usage: \(prefix) <command> [options]"
        ]
        if let description = description, !description.isEmpty {
            lines += [
                "",
                description
            ]
        }
        var commandGroups: [CommandGroup] = []
        var commands: [Command] = []
        for routable in routables {
            if let commandGroup = routable as? CommandGroup { commandGroups.append(commandGroup) }
            if let command = routable as? Command { commands.append(command) }
        }
        
        let maxNameLength = routables.reduce(12) { (length, routable) in
            if routable.name.count > length {
               return routable.name.count
            }
            return length
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
    
    public func generateUsageStatement(for command: Command, in cli: CLI) -> String {
        var message = "\nUsage: \(cli.name) \(command.usage(for: cli))\n"
        
        let options = command.options(for: cli)
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
    
    public func generateMisusedOptionsStatement(for command: Command, error: OptionRecognizerError, in cli: CLI) -> String {
        return generateUsageStatement(for: command, in: cli) + "\n" + error.message + "\n"
    }
    
}

public class DefaultHelpMessageGenerator: HelpMessageGenerator {}

@available(*, unavailable, message: "Implement HelpMessageGenerator instead")
public protocol UsageStatementGenerator {
    func generateUsageStatement(for command: Command) -> String
}

@available(*, unavailable, message: "Implement HelpMessageGenerator instead")
public protocol MisusedOptionsMessageGenerator {
    func generateMisusedOptionsStatement(for command: Command, error: OptionRecognizerError) -> String
}

