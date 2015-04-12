//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class FlagOption {
    
    public typealias FlagBlock = (flag: String) -> ()
    
    let flags: [String]
    let usage: String
    let block: FlagBlock?
    
    convenience init(flag: String, usage: String, block: FlagBlock?) {
        self.init(flags: [flag], usage: usage, block: block)
    }
    
    init(flags: [String], usage: String, block: FlagBlock?) {
        self.flags = flags
        self.block = block
        
        let flagsString = ", ".join(flags)
        let paddedUsage = usage.padFront(totalLength: 40 - count(flagsString))
        self.usage = "\(flagsString)\(paddedUsage)"
    }
    
}

public class KeyOption {
    
    public typealias KeyBlock = (key: String, value: String) -> ()
    
    let keys: [String]
    let usage: String
    let valueSignature: String
    let block: KeyBlock?
    
    convenience init(key: String, usage: String, valueSignature: String, block: KeyBlock?) {
        self.init(keys: [key], usage: usage, valueSignature: valueSignature, block: block)
    }
    
    init(keys: [String], usage: String, valueSignature: String, block: KeyBlock?) {
        self.keys = keys
        self.valueSignature = valueSignature
        self.block = block
        
        let keysString = ", ".join(keys)
        let firstPart = "\(keysString) <\(valueSignature)>"
        let paddedUsage = usage.padFront(totalLength: 40 - count(firstPart))
        self.usage = "\(firstPart)\(paddedUsage)"
    }
    
}

public class Options {
    
    var flagOptions: [String: FlagOption] = [:]
    var keyOptions: [String: KeyOption] = [:]
    
    var unrecognizedOptions: [String] = []
    var keysNotGivenValue: [String] = []
    
    // MARK: - Adding options
    
    func onFlags(flags: [String], usage: String = "", block: FlagOption.FlagBlock?) {
        addFlagOption(FlagOption(flags: flags, usage: usage, block: block))
    }
    
    func addFlagOption(flagOption: FlagOption) {
        flagOption.flags.each { self.flagOptions[$0] = flagOption }
    }
    
    func onKeys(keys: [String], usage: String = "", valueSignature: String = "value", block: KeyOption.KeyBlock?) {
        addKeyOption(KeyOption(keys: keys, usage: usage, valueSignature: valueSignature, block: block))
    }
    
    func addKeyOption(keyOption: KeyOption) {
        keyOption.keys.each { self.keyOptions[$0] = keyOption }
    }
    
    // MARK: - Argument parsing
    
    func recognizeOptionsInArguments(rawArguments: RawArguments) {
        var passedOptions: [String] = []
        rawArguments.unclassifiedArguments().each {(argument) in
            if argument.hasPrefix("-") {
                passedOptions += self.optionsForRawOption(argument)
                rawArguments.classifyArgument(argument: argument, type: .Option)
            }
        }
        
        for option in passedOptions {
            if let flagOption = flagOptions[option] {
                flagOption.block?(flag: option)
            } else if let keyOption = keyOptions[option] {
                if let keyValue = rawArguments.argumentFollowingArgument(option)
                    where !keyValue.hasPrefix("-") {
                        rawArguments.classifyArgument(argument: keyValue, type: .Option)
                        
                        keyOption.block?(key: option, value: keyValue)
                } else {
                    keysNotGivenValue.append(option)
                }
            } else {
                unrecognizedOptions.append(option)
            }
        }
    }
    
    private func optionsForRawOption(rawOption: String) -> [String] {
        if rawOption.hasPrefix("--") {
            return [rawOption]
        }
        
        var chars: [String] = []
        
        for (index, character) in enumerate(rawOption) {
            if index > 0 {
                chars.append("-\(character)")
            }
        }
        
        return chars
    }
    
    // MARK: - Misused options
    
    func misusedOptionsPresent() -> Bool {
        return unrecognizedOptions.count > 0 || keysNotGivenValue.count > 0
    }
    
    func misusedOptionsMessage() -> String {
        var message = ""
        
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
        
        return message
    }
    
}
