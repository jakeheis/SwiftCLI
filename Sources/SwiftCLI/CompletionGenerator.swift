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
    func writeCompletions(into stream: OutputByteStream)
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
    
    public func writeCompletions(into stream: OutputByteStream) {
        stream <<< "#compdef \(cli.name)"
        
        writeGroup(name: cli.name, routables: cli.commands, into: stream)
        
        stream <<< "_\(cli.name)"
    }
    
    func writeGroup(name: String, routables: [Routable], into stream: OutputByteStream) {
        stream <<< """
        _\(name)() {
            local context state line
            if (( CURRENT > 2 )); then
                (( CURRENT-- ))
                shift words
                _call_function - "_\(name)_${words[1]}" || _nothing
            else
                __\(name)_commands
            fi
        }
        """
        writeCommandList(name: name, routables: routables, into: stream)
    }
    
    func writeCommandList(name: String, routables: [Routable], into stream: OutputByteStream) {
        stream <<< """
        __\(name)_commands() {
             _arguments -C \\
               ': :->command'
             case "$state" in
                  command)
                       local -a commands
                       commands=(
        """
        
        for routable in routables {
            let info = escapeDescription(routable.shortDescription.isEmpty ? routable.name : routable.shortDescription)
            stream <<< "               \(routable.name)\"[\(info)]\""
        }
        
        stream <<< """
                       )
                       _values 'command' $commands
                       ;;
             esac
        }
        """
        
        routables.forEach { (routable) in
            if let command = routable as? Command {
                self.writeCommand(command, prefix: name, into: stream)
            } else if let group = routable as? CommandGroup {
                self.writeGroup(name: name + "_\(group.name)", routables: group.children, into: stream)
            }
        }
    }
    
    func writeCommand(_ command: Command, prefix: String, into stream: OutputByteStream) {
        stream <<< """
        _\(prefix)_\(command.name)() {
            _arguments -C \\
        """
        
        let options = command.options(for: cli)
        let lines: [String] = options.map { (option) in
            let first = "(" + option.names.joined(separator: " ") + ")"
            let middle = "{" + option.names.joined(separator: ",") + "}"
            let end: String
            if option.shortDescription.isEmpty {
                let sortedNames = option.names.sorted(by: {$0.count > $1.count})
                end = "[" + sortedNames.first!.trimmingCharacters(in: CharacterSet(charactersIn: "-")) + "]"
            } else {
                end = "[" + escapeDescription(option.shortDescription) + "]"
            }
            return "      '\(first)'\(middle)\"\(end)\""
        }
        stream <<< lines.joined(separator: " \\\n")
        
        stream <<< """
        }
        """
    }
    
    private func escapeDescription(_ description: String) -> String {
        return description.replacingOccurrences(of: "\"", with: "\\\"")
    }
    
}
