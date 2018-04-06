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

public struct RouteError: Swift.Error {
    public let partialPath: CommandGroupPath
    public let notFound: String?
}

public struct OptionError: Swift.Error {
    let command: CommandPath?
    let message: String
}

public struct ParameterError: Swift.Error {
    let command: CommandPath
    let message: String
}

public class Parse {
    
    func parse(commandGroup: CommandGroup, arguments: ArgumentList) throws -> CommandPath {
        var groupPath = CommandGroupPath(top: commandGroup)
        var command: CommandPath? = nil
        var params: ParameterIterator? = nil
        let optionRegistry = OptionRegistry(routable: commandGroup)
        
        while let node = arguments.head {
            if let alias = groupPath.bottom.aliases[node.value] {
                node.value = alias
            }
            
            defer { arguments.remove(node: node) }
            
            if node.value.hasPrefix("-") {
                if let flag = optionRegistry.flag(for: node.value) {
                    flag.setOn()
                } else if let key = optionRegistry.key(for: node.value) {
                    guard let next = node.next, !next.value.hasPrefix("-") else {
                        throw OptionError(command: command, message: "Expected a value to follow: \(node.value)")
                    }
                    guard key.setValue(next.value) else {
                        throw OptionError(command: command, message: "Illegal type passed to \(key): \(node.value)")
                    }
                    arguments.remove(node: next)
                } else {
                    throw OptionError(command: command, message:"Unrecognized option: \(node.value)")
                }
                break
            }
            
            if let command = command, let params = params {
                if let param = params.next() {
                    param.update(value: node.value)
                } else {
                    throw ParameterError(command: command, message: params.createErrorMessage())
                }
            } else {
                guard let matching = groupPath.bottom.children.first(where: { $0.name == node.value }) else {
                    throw RouteError(partialPath: groupPath, notFound: node.value)
                }
                
                optionRegistry.register(matching)
                
                if let group = matching as? CommandGroup {
                    groupPath = groupPath.appending(group)
                } else if let cmd = matching as? Command {
                    command = groupPath.appending(cmd)
                    params = ParameterIterator(command: cmd)
                } else {
                    preconditionFailure("Routables must be either CommandGroups or Commands")
                }
            }
        }
        
        guard let commandPath = command else {
            throw RouteError(partialPath: groupPath, notFound: nil)
        }
        if let params = params, let param = params.next(), !param.satisfied {
            throw ParameterError(command: commandPath, message: params.createErrorMessage())
        }
        if let failingGroup = optionRegistry.failingGroup() {
            throw OptionError(command: commandPath, message: failingGroup.message)
        }
        
        return commandPath
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
