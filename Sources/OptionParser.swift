//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

// MARK: - OptionParser

import Foundation

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
        var requiredOptionsMissing: [String:String] = [:]
        var conflictingOptions: [String:[String]] = [:]
        
        let requiredGroups = optionRegistry.requiredOptions
        
        let optionsString = (optionArguments.flatMap { (option) -> [String] in
            let value = option.value
            return [value]
        }).joined(separator: " ")
        let optionsRange = NSRange(location: 0, length: optionsString.characters.count)
        for requiredGroup in requiredGroups {
            var isCurrentGroupConflicting: Bool = true
            var groupName: String = ""
            
            if let currentGroup = (optionRegistry.groups.first { $0.name == requiredGroup.group }) {
                isCurrentGroupConflicting = currentGroup.conflicting
                groupName = currentGroup.name
            }
            
            let value = (requiredGroup.options).joined(separator:"|")
            let patternString = "((\\s(\(value))\\s)|(^(\(value))\\s)|(\\s(\(value))$))"
            let requiredRegex = try! Regex(pattern: patternString, options: [.caseInsensitive])
            
            if requiredRegex.numberOfMatches(in: optionsString.replacingOccurrences(of: " ", with: "  "), options: [], range: optionsRange) < 1 {
                requiredOptionsMissing[groupName] = value
            }
            

            if (isCurrentGroupConflicting == true) {
                
                let matches = requiredRegex.matches(in: optionsString.replacingOccurrences(of: " ", with: "  "), options: [], range: optionsRange)
                
                if (matches.count > 1) {
                    var groupConflicts: [String] = []
                    
                    for match in matches {
                        let range = match.range
                        
                        let text =  (optionsString.replacingOccurrences(of: " ", with: "  ").substring(from:range.location,length:((range.length) - 1))).replacingOccurrences(of: " ", with: "")
                        groupConflicts.append(text)
                    }
                    
                    conflictingOptions[groupName] = groupConflicts
                    
                }
            
            }
            
        }
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
        
        if !unrecognizedOptions.isEmpty || !keysNotGivenValue.isEmpty || !requiredOptionsMissing.isEmpty || !conflictingOptions.isEmpty {
            let incorrect = IncorrectOptionUsage(optionRegistry: optionRegistry, unrecognizedOptions: unrecognizedOptions, keysNotGivenValue: keysNotGivenValue, requiredOptionsMissing: requiredOptionsMissing, conflictingOptions:conflictingOptions)
            return .incorrectOptionUsage(incorrect)
        }
        
        return .success
    }
    
}

public struct IncorrectOptionUsage {
    
    public let optionRegistry: OptionRegistry
    public let unrecognizedOptions: [String]
    public let keysNotGivenValue: [String]
    public let requiredOptionsMissing: [String:String]
    public let conflictingOptions: [String:[String]]
    
    public func misusedOptionsPresent() -> Bool {
        return unrecognizedOptions.count > 0 || keysNotGivenValue.count > 0
    }
    
    public func misusedOptionsMessage() -> String {
        var message = ""
        
        if requiredOptionsMissing.count > 0 {
            
            message += "Missing options:"
            for option in requiredOptionsMissing.sorted(by:{$0.key < $1.key}) {
                message += "\n\t\(option.key):\t\(option.value)".replacingOccurrences(of:"|", with:", ", options: [])
            }
            
            message += "\n"
        }
        
        if unrecognizedOptions.count > 0 {
            message += "Unrecognized options:"
            for option in unrecognizedOptions {
                message += "\n\t\(option)"
            }
            
            message += "\n"
        }
        
        if conflictingOptions.count > 0 {
        
            message+="Conflicting options:"
            for group in conflictingOptions {
                let groupKeys = group.value.joined(separator: ", ")
                message += "\n\t\(group.key):\t\(groupKeys)"
            
            }
        
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
