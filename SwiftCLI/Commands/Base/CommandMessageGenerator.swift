//
//  CommandMessageGenerator.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import Foundation

public class CommandMessageGenerator {
    
    class func generateUsageStatement(command command: CommandType, routedName: String?, options: Options?) -> String {
        var message = "Usage: \(CLI.appName())"
        
        let name = routedName ?? command.commandName
        if !name.isEmpty {
            message += " \(name)"
        }
        
        if !command.commandSignature.isEmpty {
            message += " \(command.commandSignature)"
        }
        
        if let options = options where !options.flagOptions.isEmpty || !options.keyOptions.isEmpty {
            message += " [options]\n"
            
            let allKeys = options.flagOptions.keys.array + options.keyOptions.keys.array
            let sortedKeys = allKeys.sort()
            for key in sortedKeys {
                let usage = options.flagOptions[key]?.usage ?? options.keyOptions[key]?.usage ?? ""
                message += "\n\(usage)"
            }
            
            message += "\n"
        } else {
            message += "     (no options)\n"
        }
        
        return message
    }
    
    class func generateMisusedOptionsStatement(command command: CommandType, options: Options) -> String? {
        guard let optionsCommand = command as? OptionCommandType else {
            return nil
        }
        
        switch optionsCommand.unrecognizedOptionsPrintingBehavior {
        case .PrintNone:
            return nil
        case .PrintOnlyUsage:
            return generateUsageStatement(command: command, routedName: nil, options: options)
        case .PrintOnlyUnrecognizedOptions:
            return options.misusedOptionsMessage()
        case .PrintAll:
            return generateUsageStatement(command: command, routedName: nil, options: options) + "\n" + options.misusedOptionsMessage()
        }
    }
    
}
