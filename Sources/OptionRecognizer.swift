//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - OptionRecognizer

public protocol OptionRecognizer {
    func recognizeOptions(of command: Command, in arguments: ArgumentList) throws
}

// MARK: - DefaultOptionRecognizer

public class DefaultOptionRecognizer: OptionRecognizer {
    
    public func recognizeOptions(of command: Command, in arguments: ArgumentList) throws {
        let optionRegistry = OptionRegistry(command: command)
        
        let iterator = arguments.iterator()
        while let node = iterator.next() {
            if node.value.hasPrefix("-") {
                try handleOption(node: node, arguments: arguments, optionRegistry: optionRegistry)
            }
        }
        if let failingGroup = optionRegistry.failingGroup() {
            throw OptionRecognizerError.groupRestrictionFailed(failingGroup)
        }
    }
    
    private func handleOption(node: ArgumentNode, arguments: ArgumentList, optionRegistry: OptionRegistry) throws {
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

// MARK: - OptionRecognizerError

public enum OptionRecognizerError: Swift.Error {
    case unrecognizedOption(String)
    case illegalKeyValue(String, String)
    case noValueForKey(String)
    case groupRestrictionFailed(OptionGroup)
    
    var message: String {
        switch self {
        case .unrecognizedOption(let option):
            return "Unrecognized option: \(option)"
        case .illegalKeyValue(let key, let value):
            return "Illegal type passed to \(key): \(value)"
        case .noValueForKey(let key):
            return "Expected a value to follow: \(key)"
        case .groupRestrictionFailed(let group):
            return group.message
        }
    }
}
