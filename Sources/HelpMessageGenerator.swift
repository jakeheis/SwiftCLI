//
//  HelpMessageGenerator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

public protocol HelpMessageGenerator {
    func generateCommandList(prefix: String, description: String?, routables: [Routable]) -> String
    func generateUsageStatement(for command: Command, cliName: String) -> String
    func generateMisusedOptionsStatement(for command: Command, error: OptionRecognizerError, cliName: String) -> String
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
        
        func toLine(_ routable: Routable) -> String {
            let spacing = String(repeating: " ", count: 20 - routable.name.characters.count)
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
    
    public func generateUsageStatement(for command: Command, cliName: String) -> String {
        var message = "Usage: \(cliName) \(command.usage)\n"
        
        if !command.options.isEmpty {
            let sortedOptions = command.options.sorted { (lhs, rhs) in
                return lhs.names.first! < rhs.names.first!
            }
            for option in sortedOptions {
                let usage = option.usage
                message += "\n\(usage)"
            }
            
            message += "\n"
        }
        
        return message
    }
    
    public func generateMisusedOptionsStatement(for command: Command, error: OptionRecognizerError, cliName: String) -> String {
        return generateUsageStatement(for: command, cliName: cliName) + "\n" + error.message + "\n"
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
