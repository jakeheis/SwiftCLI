//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

typealias OptionsFlagBlock = (flag: String) -> ()
typealias OptionsKeyBlock = (key: String, value: String) -> ()

class Options {
    
    var expectedFlags: [String] = []
    var expectedFlagBlocks: [OptionsFlagBlock?] = []
    var expectedKeys: [String] = []
    var expectedKeyBlocks: [OptionsKeyBlock?] = []
    
    var unrecognizedOptions: [String] = []
    var keysNotGivenValue: [String] = []
    
    // MARK: - Argument parsing
    
    func parseCommandLineArguments(arguments: Arguments) -> [String] {
        var commandArguments: [String] = []
        
        var keyAwaitingValue: String? = nil
        
        for arg in arguments.argumentsArray {
            if arg.hasPrefix("-") {
                var allOptions = splitOption(arg)
                
                for option in allOptions {
                    if let key = keyAwaitingValue {
                        keysNotGivenValue.append(key)
                        keyAwaitingValue = nil
                    }
                    
                    if tryFlag(option) {
                        continue
                    }
                    
                    if contains(expectedKeys, option) {
                        keyAwaitingValue = option
                        continue
                    }
                    
                    unrecognizedOptions.append(arg)
                }
               
            } else {
                if let key = keyAwaitingValue {
                    foundKeyValue(key, value: arg)
                    keyAwaitingValue = nil
                } else {
                    commandArguments.append(arg)
                }
            }
        }
        
        return commandArguments
    }
    
    private func splitOption(optionString: String) -> [String] {
        var allOptions: [String] = []
        if optionString.hasPrefix("--") {
            allOptions.append(optionString)
        } else {
            var chars: [String] = characterArrayForString(optionString)
            chars.removeAtIndex(0)
            allOptions += chars.map({ "-\($0)" })
        }
        return allOptions
    }
    
    private func characterArrayForString(string: String) -> [String] {
        var chars: [String] = []
        for i in 0..<string.utf16Count {
            let index = advance(string.startIndex, i)
            let str = String(string[index])
            chars.append(str)
        }
        return chars
    }
    
    private func tryFlag(flag: String) -> Bool {
        if let index = find(expectedFlags, flag) {
            let block = expectedFlagBlocks[index]
            block?(flag: flag)
            return true
        }
        return false
    }
    
    private func foundKeyValue(key: String, value: String) {
        let index = find(expectedKeys, key)
        let block = expectedKeyBlocks[index!]
        block?(key: key, value: value)
    }
    
    // MARK: - Flags

    func onFlags(flags: [String], block: OptionsFlagBlock?) {
        for flag in flags {
            expectedFlags.append(flag)
            expectedFlagBlocks.append(block)
        }
    }
    
    // MAKR: - Keys
    
    func onKeys(keys: [String], block: OptionsKeyBlock?) {
        for key in keys {
            expectedKeys.append(key)
            expectedKeyBlocks.append(block)
        }
    }
    
    // MARK: - Other publics
    
    func misusedOptionsPresent() -> Bool {
        return unrecognizedOptions.count > 0 || keysNotGivenValue.count > 0
    }
    
    func unaccountedForMessage(#command: Command, routedName: String) -> String? {
        if command.unrecognizedOptionsPrintingBehavior() == UnrecognizedOptionsPrintingBehavior.PrintNone {
            return nil
        }
        
        var message = ""
        
        if command.unrecognizedOptionsPrintingBehavior() != .PrintOnlyUsage {
            if unrecognizedOptions.count > 0 {
                message += "Unrecognized options:"
                for option in unrecognizedOptions {
                    message += "\n\t\(option)"
                }
            }

            if keysNotGivenValue.count > 0 {
                message += "Required values for options but given none:"
                for option in keysNotGivenValue {
                    message += "\n\t\(option)"
                }
            }
            
            if command.unrecognizedOptionsPrintingBehavior() == .PrintAll {
                message += "\n" // Padding if more will be printed
            }
        }
       
        if command.unrecognizedOptionsPrintingBehavior() != .PrintOnlyUnrecognizedOptions {
            message += command.commandUsageStatement(commandName: routedName)
        }
        
        return message
    }
    
}
