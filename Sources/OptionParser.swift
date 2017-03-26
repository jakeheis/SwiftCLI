//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - OptionParser

public protocol OptionParser {
    func recognizeOptions(in arguments: ArgumentList, from optionRegistry: OptionRegistry) -> OptionParserResult
}

// MARK: - OptionParserResult

public enum OptionParserResult {
    case success
    case exitEarly
    case incorrectOptionUsage(IncorrectOptionUsage)
}

// MARK: - DefaultOptionParser

public class DefaultOptionParser: OptionParser {
    
    public func recognizeOptions(in arguments: ArgumentList, from optionRegistry: OptionRegistry) -> OptionParserResult {
        var unrecognizedOptions: [String] = []
        var keysNotGivenValue: [String] = []
        var exitEarly: Bool = false
        
        var current = arguments.head
        while let node = current {
            if node.value.hasPrefix("-") {
                if let flagBlock = optionRegistry.flagBlocks[node.value] {
                    flagBlock()
                } else if let keyBlock = optionRegistry.keyBlocks[node.value] {
                    if let next = node.next, !next.value.hasPrefix("-") {
                        keyBlock(next.value)
                        arguments.remove(node: next)
                    } else {
                        keysNotGivenValue.append(node.value)
                    }
                } else {
                    unrecognizedOptions.append(node.value)
                }
                arguments.remove(node: node)
                
                if optionRegistry.exitEarlyOptions.contains(node.value) {
                    exitEarly = true
                }
            }
            current = node.next
        }
        
        if exitEarly {
            return .exitEarly
        }
        
        if !unrecognizedOptions.isEmpty || !keysNotGivenValue.isEmpty {
            let incorrect = IncorrectOptionUsage(optionRegistry: optionRegistry, unrecognizedOptions: unrecognizedOptions, keysNotGivenValue: keysNotGivenValue)
            return .incorrectOptionUsage(incorrect)
        }
        
        return .success
    }
    
}

public struct IncorrectOptionUsage {
    
    public let optionRegistry: OptionRegistry
    public let unrecognizedOptions: [String]
    public let keysNotGivenValue: [String]
    
    public func misusedOptionsPresent() -> Bool {
        return unrecognizedOptions.count > 0 || keysNotGivenValue.count > 0
    }
    
    public func misusedOptionsMessage() -> String {
        var message = ""
        
        if unrecognizedOptions.count > 0 {
            message += "Unrecognized options:"
            for option in unrecognizedOptions {
                message += "\n\t\(option)"
            }
            
            message += "\n"
        }
        
        if keysNotGivenValue.count > 0 {
            message += "Required values for options but given none:"
            for option in keysNotGivenValue {
                message += "\n\t\(option)"
            }
            
            message += "\n"
        }
        
        return message
    }
    
}
