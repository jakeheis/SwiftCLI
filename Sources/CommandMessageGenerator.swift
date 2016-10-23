//
//  CommandMessageGenerator.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

public protocol UsageStatementGenerator {
    func generateUsageStatement(for command: Command, optionRegistry: OptionRegistry?) -> String
}

public protocol MisusedOptionsMessageGenerator {
    func generateMisusedOptionsStatement(for command: Command, incorrectOptionUsage: IncorrectOptionUsage) -> String?
}

public class DefaultUsageStatementGenerator: UsageStatementGenerator {
    
    public func generateUsageStatement(for command: Command, optionRegistry: OptionRegistry?) -> String {
        var message = command.usage
        
        if let options = optionRegistry?.options, !options.isEmpty {
            message += " [options]\n"
            
            let sortedOptions = options.sorted { (lhs, rhs) in
                return lhs.options.first! < rhs.options.first!
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

public class DefaultMisusedOptionsMessageGenerator: MisusedOptionsMessageGenerator {

    public func generateMisusedOptionsStatement(for command: Command, incorrectOptionUsage: IncorrectOptionUsage) -> String? {
        guard let optionsCommand = command as? OptionCommand else {
            return nil
        }
        
        switch optionsCommand.unrecognizedOptionsPrintingBehavior {
        case .printNone:
            return nil
        case .printOnlyUsage:
            return CLI.usageStatementGenerator.generateUsageStatement(for: command, optionRegistry: incorrectOptionUsage.optionRegistry)
        case .printOnlyUnrecognizedOptions:
            return incorrectOptionUsage.misusedOptionsMessage()
        case .printAll:
            return CLI.usageStatementGenerator.generateUsageStatement(for: command, optionRegistry: incorrectOptionUsage.optionRegistry) + "\n" + incorrectOptionUsage.misusedOptionsMessage()
        }
    }
    
}
