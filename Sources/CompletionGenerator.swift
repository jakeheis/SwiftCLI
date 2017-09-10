//
//  CompletionGenerator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/10/17.
//

protocol CompletionOutputStream {
    func output(_ content: String)
}

struct StdoutStream: CompletionOutputStream {
    func output(_ content: String) {
        print(content)
    }
}

class CaptureStream: CompletionOutputStream {
    private(set) var content: String = ""
    func output(_ content: String) {
        self.content += content + "\n"
    }
}

infix operator <<

func <<(stream: CompletionOutputStream, text: String) {
    stream.output(text)
}

protocol CompletionGenerator {
    init(cli: CLI)
    func writeCompletions(into stream: CompletionOutputStream)
}

final class ZshCompletionGenerator: CompletionGenerator {
    
    let cli: CLI
    
    init(cli: CLI) {
        self.cli = cli
    }
    
    func writeCompletions(into stream: CompletionOutputStream) {
        stream << "#compdef \(cli.name)"
        
        writeEntryFunction(into: stream)
        writeTopLevel(into: stream)
        writeCommands(into: stream)
        
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
    
    func writeTopLevel(into stream: CompletionOutputStream) {
        stream << """
        __\(cli.name)_commands() {
             _arguments -C \\
               ': :->command'
             case "$state" in
                  command)
                       local -a commands
                       commands=(
        """
        
        for command in cli.commands {
            stream << "               \(command.name)'[\(command.shortDescription)]'"
        }
        
        stream << """
                       )
                       _values 'command' $commands
                       ;;
             esac
        }
        """
    }
    
    func writeCommands(into stream: CompletionOutputStream) {
        cli.commands.flatMap { $0 as? Command }.forEach { writeCommand($0, into: stream)}
    }
    
    func writeCommand(_ command: Command, into stream: CompletionOutputStream) {
        stream << """
        _\(cli.name)_\(command.name)() {
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
