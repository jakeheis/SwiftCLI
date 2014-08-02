//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Options {
    
    let combinedFlagsAndKeys: [String]
    var flagOptions: [String] = []
    var keyedOptions: [String: String] = [:]
    
    var accountedForFlags: [String] = []
    var accountedForKeys: [String] = []
    
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
    
    func onFlag(flag: String, block: ( (flag: String) -> () )?) -> Bool {
        if contains(self.flagOptions, flag) {
            self.accountedForFlags += flag
            block?(flag: flag)
            return true
        }
        return false
    }
    
    func onFlags(flags: [String], block: ( (flag: String) -> () )) {
        for flag in flags {
            self.onFlag(flag, block: block)
        }
    }
    
    func onKey(option: String, block: ( (option: String, arg: String) -> () )?) {
        if contains(Array(self.keyedOptions.keys), option) {
            self.accountedForKeys += option
            block?(option: option, arg: self.keyedOptions[option]!)
        }
    }
    
    func handleAll() {
        self.accountedForFlags = self.flagOptions
        self.accountedForKeys = Array(self.keyedOptions.keys)
    }

    func allAccountedFor() -> Bool {
        return self.remainingFlags().count == 0 && self.remainingOptions().count == 0
    }
    
    func remainingFlags() -> [String] {
        let remainingFlags = NSMutableArray(array: self.flagOptions)
        remainingFlags.removeObjectsInArray(self.accountedForFlags)
        var stringArray = NSArray(array: remainingFlags) as [String]
        return stringArray
    }
    
    func remainingOptions() -> [String] {
        let remainingOptions = NSMutableArray(array: Array(self.keyedOptions.keys))
        remainingOptions.removeObjectsInArray(self.accountedForKeys)
        var stringArray = NSArray(array: remainingOptions) as [String]
        return stringArray
    }
    
    func unaccountedForMessage() -> String {
        var starter = "Unrecognized flags and options:"
        for flag in self.remainingFlags() {
            starter += "\n \(flag)"
        }
        for option in self.remainingOptions() {
            starter += "\n \(option): \(self.keyedOptions[option])"
        }
        return starter
    }
    
}