//
//  CompletionGenerator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/10/17.
//

import Foundation

public enum ShellCompletion {
    case none
    case filename
    case values([(name: String, description: String)])
    case function(String)
}

public protocol CompletionGenerator {
    init(cli: CLI)
    init(cli: CLI, functions: [String: String])
    func writeCompletions()
    func writeCompletions(into stream: WritableStream)
}

public final class ZshCompletionGenerator: CompletionGenerator {
    
    public let cli: CLI
    public let functions: [String: String]
    
    public convenience init(cli: CLI) {
        self.init(cli: cli, functions: [:])
    }
    
    public init(cli: CLI, functions: [String: String]) {
        self.cli = cli
        self.functions = functions
    }
    
    public func writeCompletions() {
        writeCompletions(into: Term.stdout)
    }
    
    public func writeCompletions(into stream: WritableStream) {
        stream <<< """
        #compdef \(cli.name)
        local context state state_descr line
        typeset -A opt_args
        
        """
        
        writeGroup(for: CommandGroupPath(top: cli), into: stream)
        
        functions.forEach { writeFunction(name: $0.key, body: $0.value, into: stream) }
        
        stream <<< "_\(cli.name)"
    }
    
    func writeGroup(for group: CommandGroupPath, into stream: WritableStream) {
        let name = functionName(for: group)
        
        let options = genOptionArgs(for: group.bottom).joined(separator: " \\\n")
        let commandList = group.bottom.children.map { (child) in
            return "            \"\(child.name):\(escapeDescription(child.shortDescription))\""
        }.joined(separator: "\n")
        
        
        let subcommands = group.bottom.children.map { (child) -> String in
            let indentation = "                "
            return """
            \(indentation)(\(child.name))
            \(indentation)    _\(functionName(for: group.appending(child)))
            \(indentation)    ;;
            """
        }.joined(separator: "\n")
        
        stream <<< """
        _\(name)() {
            _arguments -C \\
        """
        if !options.isEmpty {
            stream <<< options + " \\"
        }
        stream <<< """
              '(-): :->command' \\
              '(-)*:: :->arg' && return
            case $state in
                (command)
                    local commands
                    commands=(
        \(commandList)
                    )
                    _describe 'command' commands
                    ;;
                (arg)
                    case ${words[1]} in
        \(subcommands)
                    esac
                    ;;
            esac
        }
        """
        
        group.bottom.children.forEach { (routable) in
            if let subGroup = routable as? CommandGroup {
                self.writeGroup(for: group.appending(subGroup), into: stream)
            } else if let command = routable as? Command {
                self.writeCommand(for: group.appending(command), into: stream)
            }
        }
    }
    
    func writeCompletion(_ completion: ShellCompletion) -> String {
        switch completion {
        case .filename:
            return "_files"
        case .none:
            return " "
        case .values(let vals):
            let valPortion = vals.map { (value) in
                var line = "'\(value.name)"
                if !value.description.isEmpty {
                    line += "[\(value.description)]"
                }
                line += "'"
                return line
            }.joined(separator: " ")
            return "{_values '' \(valPortion)}"
        case .function(let function):
            return function
        }
    }
    
    func writeCommand(for command: CommandPath, into stream: WritableStream) {
        let optionArgs = genOptionArgs(for: command.command).joined(separator: " \\\n")
        let paramArgs = command.command.parameters.map { (namedParam) -> String in
            var line = "      \""
            if namedParam.param is AnyCollectedParameter {
                line += "*"
            }
            line += ":"
            if !namedParam.param.required {
                line += ":"
            }
            line += "\(namedParam.name):\(writeCompletion(namedParam.param.completion))"
            line += "\""
            return line
        }.joined(separator: " \\\n")
        
        let name = functionName(for: command)
        stream <<< """
        _\(name)() {
            _arguments -C\(optionArgs.isEmpty && paramArgs.isEmpty ? "" : " \\")
        """
        if !optionArgs.isEmpty {
            stream <<< optionArgs + (paramArgs.isEmpty ? "" : " \\")
        }
        if !paramArgs.isEmpty {
            stream <<< paramArgs
        }
        stream <<< "}"
    }
    
    func writeFunction(name: String, body: String, into stream: WritableStream) {
        let lines = body.components(separatedBy: "\n").map { "    " + $0 }.joined(separator: "\n")
        stream <<< """
        \(name)() {
        \(lines)
        }
        """
    }
    
    // MARK: - Helpers
    
    enum OptionWritingMode {
        case normal
        case additionalExclusive([String])
        case variadic
    }
    
    private func genOptionLine(names: [String], mode: OptionWritingMode, description: String, completion: ShellCompletion?) -> String {
        precondition(names.count > 0)
        
        var line = "      "
        
        let mutuallyExclusive: [String]
        switch mode {
        case .normal:
            mutuallyExclusive = names.count > 1 ? names : []
        case .additionalExclusive(let exclusive): mutuallyExclusive = exclusive
        case .variadic:
            precondition(names.count == 1)
            mutuallyExclusive = []
        }
        
        if !mutuallyExclusive.isEmpty {
            line += "'(\(mutuallyExclusive.joined(separator: " ")))'"
        }
        
        if names.count > 1 {
            line += "{\(names.joined(separator: ","))}\"["
        } else {
            line += "\""
            if case .variadic = mode {
                line += "*"
            }
            line += "\(names[0])["
        }
        
        line += escapeDescription(description) + "]"
        
        if let completion = completion {
            line += ": :\(writeCompletion(completion))"
        }
        
        line += "\""
        return line
    }
    
    private func genOptionArgs(for routable: Routable) -> [String] {
        let lines = routable.options.map { (option) -> [String] in
            let completion: ShellCompletion?
            if let key = option as? AnyKey {
                completion = key.completion
            } else {
                completion = nil
            }
            
            if option.variadic {
                return option.names.map { (name) in
                    return genOptionLine(names: [name], mode: .variadic, description: option.shortDescription, completion: completion)
                }
            }
            for group in routable.optionGroups where group.restriction != .atLeastOne {
                if group.options.contains(where: { $0 === option }) {
                    let exclusive = Array(group.options.map({ $0.names }).joined())
                    return [genOptionLine(names: option.names, mode: .additionalExclusive(exclusive), description: option.shortDescription, completion: completion)]
                }
            }
            return [genOptionLine(names: option.names, mode: .normal, description: option.shortDescription, completion: completion)]
        }
        return Array(lines.joined())
    }
    
    private func escapeDescription(_ description: String) -> String {
        // @see `man bash` and search for "Enclosing characters in double quotes"
        return description
            .replacingOccurrences(of: #"\"#, with: #"\\"#)
            .replacingOccurrences(of: "\"", with: "\\\"") // (") -> (\")
            .replacingOccurrences(of: #"`"#, with: #"\`"#)
            .replacingOccurrences(of: #"$"#, with: #"\$"#)
    }
    
    private func functionName(for routable: RoutablePath) -> String {
        return routable.joined(separator: "_")
    }
    
}
