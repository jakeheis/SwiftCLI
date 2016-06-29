//
//  CommandMessageGenerator.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

public protocol UsageStatementGenerator {
    func generateUsageStatement(for command: CommandType, optionRegistry: OptionRegistry?) -> String
}

public protocol MisusedOptionsMessageGenerator {
    func generateMisusedOptionsStatement(for command: CommandType, incorrectOptionUsage: IncorrectOptionUsage) -> String?
}

class DefaultUsageStatementGenerator: UsageStatementGenerator {
    
    func generateUsageStatement(for command: CommandType, optionRegistry: OptionRegistry?) -> String {
        var message = "Usage: \(CLI.name)"
        
        if !command.name.isEmpty {
            message += " \(command.name)"
        }
        
        if !command.signature.isEmpty {
            message += " \(command.signature)"
        }
        
        if let options = optionRegistry?.options where !options.isEmpty {
            message += " [options]\n"
            
            let sortedOptions = options.sorted { (lhs, rhs) in
                return lhs.options.first < rhs.options.first
            }
            for option in sortedOptions {
                let usage = option.usage
                message += "\n\(usage)"
            }
            
            message += "\n"
        } else {
            message += "     (no options)\n"
        }
        
        return message
    }
    
}

class DefaultMisusedOptionsMessageGenerator: MisusedOptionsMessageGenerator {

    func generateMisusedOptionsStatement(for command: CommandType, incorrectOptionUsage: IncorrectOptionUsage) -> String? {
        guard let optionsCommand = command as? OptionCommandType else {
            return nil
        }
        
        switch optionsCommand.unrecognizedOptionsPrintingBehavior {
        case .PrintNone:
            return nil
        case .PrintOnlyUsage:
            return CLI.usageStatementGenerator.generateUsageStatement(for: command, optionRegistry: incorrectOptionUsage.optionRegistry)
        case .PrintOnlyUnrecognizedOptions:
            return incorrectOptionUsage.misusedOptionsMessage()
        case .PrintAll:
            return CLI.usageStatementGenerator.generateUsageStatement(for: command, optionRegistry: incorrectOptionUsage.optionRegistry) + "\n" + incorrectOptionUsage.misusedOptionsMessage()
        }
    }
    
}
