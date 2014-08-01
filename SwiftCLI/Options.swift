//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Options {
    
    let combinedFlagsAndOptions: [String]
    var flags: [String]
    var options: [String: String]
    
    var accountedForFlags: [String] = []
    var accountedForOptions: [String] = []
    
    init(args: [String]) {
        flags = [String]()
        options = [String: String]()
        combinedFlagsAndOptions = args
        
        super.init()
        
        splitArguments()
    }
    
    func splitArguments() {
        var skipNext = false
        for index in 0..<combinedFlagsAndOptions.count {
            if skipNext {
                skipNext = false
                continue
            }
            
            let argument = combinedFlagsAndOptions[index]
            
            if index < combinedFlagsAndOptions.count-1 {
                let nextArgument = combinedFlagsAndOptions[index+1]
                
                if nextArgument.hasPrefix("-") {
                    flags += argument
                } else {
                    options[argument] = nextArgument
                    skipNext = true
                }
                
            } else {
                flags += argument
            }
            
        }
    }
    
    func description() -> String {
        return "Flags: \(flags) Options: \(options)"
    }
    
    func onFlag(flag: String, block: ( (flag: String) -> () )?) -> Bool {
        if contains(self.flags, flag) {
            accountedForFlags += flag
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
    
    func onOption(option: String, block: ( (option: String, arg: String) -> () )?) {
        if contains(Array(self.options.keys), option) {
            accountedForOptions += option
            block?(option: option, arg: self.options[option]!)
        }
    }
    
    func handleAll() {
        self.accountedForFlags = self.flags
        self.accountedForOptions = Array(self.options.keys)
    }

    func allAccountedFor() -> Bool {
        return self.remainingFlags().count == 0 && self.remainingOptions().count == 0
    }
    
    func remainingFlags() -> [String] {
        let remainingFlags = NSMutableArray(array: self.flags)
        remainingFlags.removeObjectsInArray(self.accountedForFlags)
        var stringArray = NSArray(array: remainingFlags) as [String]
        return stringArray
    }
    
    func remainingOptions() -> [String] {
        let remainingOptions = NSMutableArray(array: Array(self.options.keys))
        remainingOptions.removeObjectsInArray(self.accountedForOptions)
        var stringArray = NSArray(array: remainingOptions) as [String]
        return stringArray
    }
    
    func unaccountedForMessage() -> String {
        var starter = "Unrecognized flags and options:"
        for flag in self.remainingFlags() {
            starter += "\n \(flag)"
        }
        for option in self.remainingOptions() {
            starter += "\n \(option): \(self.options[option])"
        }
        return starter
    }
    
}