//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - OptionParser

public protocol OptionParser {
    func recognizeOptions(in rawArguments: RawArguments, from optionRegistry: OptionRegistry) -> OptionParserResult
}

// MARK: - OptionParserResult

public enum OptionParserResult {
    case success
    case exitEarly
    case incorrectOptionUsage(IncorrectOptionUsage)
}

// MARK: - DefaultOptionParser

public class DefaultOptionParser: OptionParser {
    
    public func recognizeOptions(in rawArguments: RawArguments, from optionRegistry: OptionRegistry) -> OptionParserResult {
        let optionArguments = rawArguments.unclassifiedArguments.filter { $0.value.hasPrefix("-") }
        
        var unrecognizedOptions: [String] = []
        var keysNotGivenValue: [String] = []
        var exitEarly: Bool = false
        
        for optionArgument in optionArguments {
            optionArgument.classification = .option
            if let flagBlock = optionRegistry.flagBlocks[optionArgument.value] {
                flagBlock()
            } else if let keyBlock = optionRegistry.keyBlocks[optionArgument.value] {
                if let nextArgument = optionArgument.next, nextArgument.isUnclassified && !nextArgument.value.hasPrefix("-") {
                    nextArgument.classification = .option
                    keyBlock(nextArgument.value)
                } else {
                    keysNotGivenValue.append(optionArgument.value)
                }
            } else {
                unrecognizedOptions.append(optionArgument.value)
            }
            
            if optionRegistry.exitEarlyOptions.contains(optionArgument.value) {
                exitEarly = true
            }
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
