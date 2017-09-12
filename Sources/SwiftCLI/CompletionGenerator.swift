//
//  CompletionGenerator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/10/17.
//

import Foundation

public enum Shell {
    case bash
    case zsh
}

public protocol CompletionGenerator {
    var shell: Shell { get }
    
    init(cli: CLI)
    func writeCompletions()
    func writeCompletions(into stream: OutputStream)
}

public final class ZshCompletionGenerator: CompletionGenerator {
    
    public let cli: CLI
    public let shell = Shell.zsh
    
    public init(cli: CLI) {
        self.cli = cli
    }
    
    public func writeCompletions() {
        writeCompletions(into: StdoutStream())
    }
    
    public func writeCompletions(into stream: OutputStream) {
        stream << "#compdef \(cli.name)"
        
        writeEntryFunction(into: stream)
        writeCommandList(routables: cli.commands, prefix: cli.name, into: stream)
        
        stream << "_\(cli.name)"
    }
    
    func writeEntryFunction(into stream: OutputStream) {
        stream << """
        _\(cli.name)() {
            local context state line
            if (( CURRENT > 2 )); then
                (( CURRENT-- ))
                shift words
                _call_function - "_\(cli.name)_${words[1]}" || _nothing
            else
                __\(cli.name)_commands
            fi
        }
        """
    }
    
    func writeCommandList(routables: [Routable], prefix: String, into stream: OutputStream) {
        stream << """
        __\(prefix)_commands() {
             _arguments -C \\
               ': :->command'
             case "$state" in
                  command)
                       local -a commands
                       commands=(
        """
        
        for routable in routables {
            let info = routable.shortDescription.isEmpty ? routable.name : routable.shortDescription
            stream << "               \(routable.name)'[\(info)]'"
        }
        
        stream << """
                       )
                       _values 'command' $commands
                       ;;
             esac
        }
        """
        
        routables.forEach { (routable) in
            if let command = routable as? Command {
                self.writeCommand(command, prefix: prefix, into: stream)
            } else if let group = routable as? CommandGroup {
                self.writeCommandList(routables: group.children, prefix: prefix + "_\(group.name)", into: stream)
            }
        }
    }
    
    func writeCommand(_ command: Command, prefix: String, into stream: OutputStream) {
        stream << """
        _\(prefix)_\(command.name)() {
            _arguments -C \\
        """
        
        let options = command.options
        let lines: [String] = options.map { (option) in
            let first = "(" + option.names.joined(separator: " ") + ")"
            let middle = "{" + option.names.joined(separator: ",") + "}"
            let end: String
            if option.shortDescription.isEmpty {
                let sortedNames = option.names.sorted(by: {$0.characters.count > $1.characters.count})
                end = "[" + sortedNames.first!.trimmingCharacters(in: CharacterSet(charactersIn: "-")) + "]"
            } else {
                end = "[" + option.shortDescription + "]"
            }
            return "      '\(first)'\(middle)'\(end)'"
        }
        stream << lines.joined(separator: " \\\n")
        
        stream << """
        }
        """
    }
    
}
