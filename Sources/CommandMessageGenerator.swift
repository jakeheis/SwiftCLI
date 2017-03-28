//
//  CommandMessageGenerator.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

public protocol UsageStatementGenerator {
    func generateUsageStatement(for command: Command) -> String
}

public protocol MisusedOptionsMessageGenerator {
    func generateMisusedOptionsStatement(for command: OptionCommand, error: OptionParserError) -> String?
}

public class DefaultUsageStatementGenerator: UsageStatementGenerator {
    
    public func generateUsageStatement(for command: Command) -> String {
        var message = command.usage
        
        if let optionCommand = command as? OptionCommand, !optionCommand.options.isEmpty {
            message += " [options]\n"
            
            let sortedOptions = optionCommand.options.map({ $0.1 }).sorted { (lhs, rhs) in
                return lhs.names.first! < rhs.names.first!
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

    public func generateMisusedOptionsStatement(for command: OptionCommand, error: OptionParserError) -> String? {
        switch command.unrecognizedOptionsPrintingBehavior {
        case .printNone:
            return nil
        case .printOnlyUsage:
            return CLI.usageStatementGenerator.generateUsageStatement(for: command)
        case .printOnlyUnrecognizedOptions:
            return error.message
        case .printAll:
            return CLI.usageStatementGenerator.generateUsageStatement(for: command) + "\n" + error.message
        }
    }
    
}
