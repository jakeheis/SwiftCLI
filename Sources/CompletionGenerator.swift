//
//  CompletionGenerator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/10/17.
//

public enum Shell {
    case bash
    case zsh
}

public protocol CompletionGenerator {
    var shell: Shell { get }
    
    init(cli: CLI)
    func writeCompletions(into stream: CompletionOutputStream)
}

public final class ZshCompletionGenerator: CompletionGenerator {
    
    public let cli: CLI
    public let shell = Shell.zsh
    
    public init(cli: CLI) {
        self.cli = cli
    }
    
    public func writeCompletions(into stream: CompletionOutputStream = StdoutStream()) {
        stream << "#compdef \(cli.name)"
        
        writeEntryFunction(into: stream)
        writeCommandList(routables: cli.commands, prefix: cli.name, into: stream)
        
        stream << "_\(cli.name)"
    }
    
    func writeEntryFunction(into stream: CompletionOutputStream) {
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
    
    func writeCommandList(routables: [Routable], prefix: String, into stream: CompletionOutputStream) {
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
            stream << "               \(routable.name)'[\(routable.shortDescription)]'"
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
    
    func writeCommand(_ command: Command, prefix: String, into stream: CompletionOutputStream) {
        stream << """
        _\(prefix)_\(command.name)() {
            _arguments -C \\
        """
        
        let options = command.options
        let lines: [String] = options.map { (option) in
            let first = "(" + option.names.joined(separator: " ") + ")"
            let middle = "{" + option.names.joined(separator: ",") + "}"
            let end = "[" + option.shortDescription + "]"
            return "      '\(first)'\(middle)'\(end)'"
        }
        stream << lines.joined(separator: " \\\n")
        
        stream << """
        }
        """
    }
    
}

// MARK: - Streams

public protocol CompletionOutputStream {
    func output(_ content: String)
}

public struct StdoutStream: CompletionOutputStream {
    public init() {}
    public func output(_ content: String) {
        print(content)
    }
}

public class CaptureStream: CompletionOutputStream {
    private(set) var content: String = ""
    public init() {}
    public func output(_ content: String) {
        self.content += content + "\n"
    }
}

infix operator <<

func <<(stream: CompletionOutputStream, text: String) {
    stream.output(text)
}
