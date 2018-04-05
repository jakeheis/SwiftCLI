//
//  ParameterFiller.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - ParameterFiller

/// Protcol representing an object which parses the arguments for a command from an argument list
public protocol ParameterFiller {
    func fillParameters(of signature: CommandSignature, with arguments: ArgumentList) throws
}

public class Parse {

    func parse(arguments: ArgumentList, command: CommandPath) throws {
        let params = ParameterIterator(command: command.command)
        let options = OptionRegistry(options: command.options, optionGroups: command.command.optionGroups)
        
        var cur = arguments.head
        while let arg = cur {
            if arg.value.hasPrefix("-") {
                try handleOption(node: arg, arguments: arguments, optionRegistry: options)
            } else if let param = params.next() {
                param.update(value: arg.value)
            } else {
                throw CLI.Error(message: "nope")
            }
            cur = arg.next
            arguments.remove(node: arg)
        }
    }
    
    private func handleOption(node: ArgumentNode, arguments: ArgumentList, optionRegistry: OptionRegistry) throws {
        print("handling \(node.value)")
        if let flag = optionRegistry.flag(for: node.value) {
            flag.setOn()
        } else if let key = optionRegistry.key(for: node.value) {
            guard let next = node.next, !next.value.hasPrefix("-") else {
                throw OptionRecognizerError.noValueForKey(node.value)
            }
            guard key.setValue(next.value) else {
                throw OptionRecognizerError.illegalKeyValue(node.value, next.value)
            }
            arguments.remove(node: next)
        } else {
            throw OptionRecognizerError.unrecognizedOption(node.value)
        }
        arguments.remove(node: node)
    }
    
}

// MARK: - DefaultParameterFiller

public class DefaultParameterFiller: ParameterFiller {
    
    public init() {}
    
    public func fillParameters(of signature: CommandSignature, with arguments: ArgumentList) throws {
        let gotCount = arguments.count()
        
        // First satisfy required parameters
        for parameter in signature.required {
            guard let next = arguments.head else {
                throw wrongArgCount(signature: signature, got: gotCount)
            }
            parameter.update(value: next.value)
            arguments.remove(node: next)
        }
        
        // Then optional parameters
        for parameter in signature.optional {
            guard let next = arguments.head else {
                break
            }
            parameter.update(value: next.value)
            arguments.remove(node: next)
        }
        
        // Finally collect remaining arguments if need be
        if let collected = signature.collected {
            var last: [String] = []
            while let node = arguments.head {
                last.append(node.value)
                arguments.remove(node: node)
            }
            if last.isEmpty {
                if collected.required {
                    throw wrongArgCount(signature: signature, got: gotCount)
                }
            } else {
                collected.update(value: last)
            }
        }
        
        // ArgumentList should be empty; if not, user passed too many arguments
        if arguments.head != nil {
            throw wrongArgCount(signature: signature, got: gotCount)
        }
    }
    
    func wrongArgCount(signature: CommandSignature, got: Int) -> CLI.Error {
        var requiredCount = signature.required.count
        if signature.collected?.required == true {
            requiredCount += 1
        }
        let optionalCount = signature.optional.count
        
        let plural = requiredCount == 1 ? "argument" : "arguments"
        if signature.collected != nil {
            return CLI.Error(message: "error: command requires at least \(requiredCount) \(plural), got \(got)")
        }
        if optionalCount == 0 {
            return CLI.Error(message: "error: command requires exactly \(requiredCount) \(plural), got \(got)")
        }
        return CLI.Error(message: "error: command requires between \(requiredCount) and \(requiredCount + optionalCount) arguments, got \(got)")
    }
    
}
