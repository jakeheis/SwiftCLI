//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - OptionParser

public protocol OptionParser {
    func recognizeOptions(in arguments: ArgumentList, from optionRegistry: OptionRegistry) throws
}

// MARK: - DefaultOptionParser

public enum OptionParserError: Swift.Error {
    case unrecognizedOption(String)
    case illegalKeyValue(String, String)
    case noValueForKey(String)
    
    var message: String {
        switch self {
        case .unrecognizedOption(let option):
            return "Unrecognized option: \(option)"
        case .illegalKeyValue(let key, let value):
            return "Illegal type passed to \(key): \(value)"
        case .noValueForKey(let key):
            return "Expected a value to follow: \(key)"
        }
    }
}

public class DefaultOptionParser: OptionParser {
    
    public func recognizeOptions(in arguments: ArgumentList, from optionRegistry: OptionRegistry) throws {
        var current = arguments.head
        while let node = current {
            if node.value.hasPrefix("-") {
                if let flag = optionRegistry.flags[node.value] {
                    flag.setOn()
                } else if let key = optionRegistry.keys[node.value]{
                    if let next = node.next, !next.value.hasPrefix("-") {
                        do {
                            try key.setValue(next.value)
                        } catch {
                            throw OptionParserError.illegalKeyValue(node.value, next.value)
                        }
                        arguments.remove(node: next)
                    } else {
                        throw OptionParserError.noValueForKey(node.value)
                    }
                } else {
                    throw OptionParserError.unrecognizedOption(node.value)
                }
                arguments.remove(node: node)
            }
            current = node.next
        }
    }
    
}

