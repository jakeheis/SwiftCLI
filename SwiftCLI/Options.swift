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
    
    func parseArguments(arguments: [String]) -> [String] {
        var commandArguments: [String] = []
        
        var keyAwaitingValue: String? = nil
        
        for arg in arguments {
            if arg.hasPrefix("-") {
                var allOptions = self.splitOption(arg)
                
                for option in allOptions {
                    if let key = keyAwaitingValue {
                        self.keysNotGivenValue.append(key)
                        keyAwaitingValue = nil
                    }
                    
                    if self.tryFlag(option) {
                        continue;
                    }
                    
                    if contains(self.expectedKeys, option) {
                        keyAwaitingValue = option
                        continue;
                    }
                    
                    self.unrecognizedOptions.append(arg)
                }
               
            } else {
                if let key = keyAwaitingValue {
                    self.foundKeyValue(key, value: arg)
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
            var chars: [String] = self.characterArrayForString(optionString)
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
        if let index = find(self.expectedFlags, flag) {
            let block = self.expectedFlagBlocks[index]
            block?(flag: flag);
            return true
        }
        return false
    }
    
    private func foundKeyValue(key: String, value: String) {
        let index = find(self.expectedKeys, key)
        let block = self.expectedKeyBlocks[index!]
        block?(key: key, value: value)
    }
    
    // MARK: - Flags

    func onFlags(flags: [String], block: OptionsFlagBlock?) {
        for flag in flags {
            self.expectedFlags.append(flag)
            self.expectedFlagBlocks.append(block)
        }
    }
    
    // MAKR: - Keys
    
    func onKeys(keys: [String], block: OptionsKeyBlock?) {
        for key in keys {
            self.expectedKeys.append(key)
            self.expectedKeyBlocks.append(block)
        }
    }
    
    // MARK: - Other publics
    
    func misusedOptionsPresent() -> Bool {
        return self.unrecognizedOptions.count > 0 || self.keysNotGivenValue.count > 0
    }
    
    func unaccountedForMessage(#command: Command, routedName: String) -> String? {
        if command.unrecognizedOptionsPrintingBehavior() == UnrecognizedOptionsPrintingBehavior.PrintNone {
            return nil
        }
        
        var message = ""
        
        if command.unrecognizedOptionsPrintingBehavior() != .PrintOnlyUsage {
            if self.unrecognizedOptions.count > 0 {
                message += "Unrecognized options:"
                for option in self.unrecognizedOptions {
                    message += "\n\t\(option)"
                }
            }

            if self.keysNotGivenValue.count > 0 {
                message += "Required values for options but given none:"
                for option in self.keysNotGivenValue {
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
