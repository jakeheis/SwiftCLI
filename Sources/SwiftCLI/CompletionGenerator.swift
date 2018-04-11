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
    func writeCompletions(into stream: WritableStream)
}

public final class ZshCompletionGenerator: CompletionGenerator {
    
    public let cli: CLI
    public let shell = Shell.zsh
    
    public init(cli: CLI) {
        self.cli = cli
    }
    
    public func writeCompletions() {
        writeCompletions(into: WriteStream.stdout)
    }
    
    public func writeCompletions(into stream: WritableStream) {
        stream <<< "#compdef \(cli.name)"
        
        writeGroupHeader(for: CommandGroupPath(top: cli), into: stream)
        
        stream <<< "_\(cli.name)"
    }
    
    func writeGroupHeader(for group: CommandGroupPath, into stream: WritableStream) {
        let name = groupName(for: group)
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
        writeCommandList(for: group, into: stream)
    }
    
    func writeCommandList(for group: CommandGroupPath, into stream: WritableStream) {
        let name = groupName(for: group)
        stream <<< """
        __\(name)_commands() {
             _arguments -C \\
               ': :->command'
             case "$state" in
                  command)
                       local -a commands
                       commands=(
        """
        
        for routable in group.bottom.children {
            if routable is HelpCommand { continue }
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
        
        group.bottom.children.forEach { (routable) in
            if routable is HelpCommand { return }
            if let subGroup = routable as? CommandGroup {
                self.writeGroupHeader(for: group.appending(subGroup), into: stream)
            } else if let command = routable as? Command {
                self.writeCommand(for: group.appending(command), into: stream)
            }
        }
    }
    
    func writeCommand(for command: CommandPath, into stream: WritableStream) {
        let prefix = groupName(for: command.groupPath!)
        stream <<< """
        _\(prefix)_\(command.command.name)() {
            _arguments -C \\
        """
        
        let lines: [String] = command.options.map { (option) in
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
    
    private func groupName(for group: CommandGroupPath) -> String {
        return group.joined(separator: "_")
    }
    
}
