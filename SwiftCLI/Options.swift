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
    
    let combinedFlagsAndKeys: [String]
    var flagOptions: [String] = []
    var keyedOptions: [String: String] = [:]
    
    var accountedForFlags: [String] = []
    var accountedForKeys: [String] = []
    
    var usageStatements: [String] = []
    
    init(args: [String]) {
        self.combinedFlagsAndKeys = args
        
        self.splitArguments()
    }
    
    func splitArguments() {
        var skipNext = false
        for index in 0..<self.combinedFlagsAndKeys.count {
            if skipNext {
                skipNext = false
                continue
            }
            
            let argument = self.combinedFlagsAndKeys[index]
            
            if index < self.combinedFlagsAndKeys.count-1 {
                let nextArgument = self.combinedFlagsAndKeys[index+1]
                
                if nextArgument.hasPrefix("-") {
                    self.flagOptions += argument
                } else {
                    self.keyedOptions[argument] = nextArgument
                    skipNext = true
                }
                
            } else {
                self.flagOptions += argument
            }
            
        }
    }
    
    func description() -> String {
        return "Flag options: \(self.flagOptions) Keyed options: \(self.keyedOptions)"
    }
    
    // Flags

    func onFlag(flag: String, block: OptionsFlagBlock?) {
        self.onFlag(flag, block: block, usage: "")
    }
    
    func onFlag(flag: String, block: OptionsFlagBlock?, usage: String?) {
        if contains(self.flagOptions, flag) {
            self.accountedForFlags += flag
            block?(flag: flag)
        }
        
        if usage {
            self.usageStatements += "\(flag)\t\t\(usage!)"
        }
    }

    func onFlags(flags: [String], block: OptionsFlagBlock?) {
        return self.onFlags(flags, block: block, usage: "")
    }
    
    func onFlags(flags: [String], block: OptionsFlagBlock?, usage: String?) {
        for flag in flags {
            self.onFlag(flag, block: block, usage: nil)
        }
        
        if usage {
            let nsFlags = flags as NSArray
            let comps = nsFlags.componentsJoinedByString(", ")
            self.usageStatements += "\(comps)\t\t\(usage!)"
        }
    }
    
    // Keys

    func onKey(key: String, block: OptionsKeyBlock?) {
        self.onKey(key, block: block, usage: "")
    }

    func onKey(key: String, block: OptionsKeyBlock?, usage: String?) {
        self.onKey(key, block: block, usage: usage, valueSignature: "value")
    }
    
    func onKey(key: String, block: OptionsKeyBlock?, usage: String?, valueSignature: String?) {
        if contains(Array(self.keyedOptions.keys), key) {
            self.accountedForKeys += key
            block?(key: key, value: self.keyedOptions[key]!)
        }
        
        if usage {
            self.usageStatements += "\(key) <\(valueSignature!)>\t\t\(usage!)"
        }
    }
    
    func onKeys(keys: [String], block: OptionsKeyBlock?) {
        self.onKeys(keys, block: block, usage: "")
    }
    
    func onKeys(keys: [String], block: OptionsKeyBlock?, usage: String?) {
        self.onKeys(keys, block: block, usage: usage, valueSignature: "value")
    }
    
    func onKeys(keys: [String], block: OptionsKeyBlock?, usage: String?, valueSignature: String?) {
        for key in keys {
            self.onKey(key, block: block, usage: nil, valueSignature: nil)
        }
        
        if usage {
            let nsFlags = keys as NSArray
            let comps = nsFlags.componentsJoinedByString(", ")
            self.usageStatements += "\(comps) <\(valueSignature!)>\t\t\(usage!)"
        }
    }
    
    // Other publics

    func allAccountedFor() -> Bool {
        return self.remainingFlags().count == 0 && self.remainingOptions().count == 0
    }
    
    func unaccountedForMessage(#command: Command) -> String {
        var message = "Unrecognized options:"
        for flag in self.remainingFlags() {
            message += "\n\t\(flag)"
        }
        for option in self.remainingOptions() {
            message += "\n\t\(option) \(self.keyedOptions[option]!)"
        }
        
        message += "\nUsage: \(CLIName) \(command.commandName()) \(command.commandSignature())"

        for usage in self.usageStatements {
            message += "\n\t\(usage)"
        }
        
        return message
    }
    
    // Privates
    
    private func remainingFlags() -> [String] {
        let remainingFlags = NSMutableArray(array: self.flagOptions)
        remainingFlags.removeObjectsInArray(self.accountedForFlags)
        var stringArray = NSArray(array: remainingFlags) as [String]
        return stringArray
    }
    
    private func remainingOptions() -> [String] {
        let remainingOptions = NSMutableArray(array: Array(self.keyedOptions.keys))
        remainingOptions.removeObjectsInArray(self.accountedForKeys)
        var stringArray = NSArray(array: remainingOptions) as [String]
        return stringArray
    }
    
}