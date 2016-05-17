//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

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
        
        let flagsString = flags.joined(separator: ", ")
        let paddedUsage = usage.padFront(totalLength: 40 - flagsString.characters.count)
        self.usage = "\(flagsString)\(paddedUsage)"
    }
    
}

public class KeyOption: Equatable {
    
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
        
        let keysString = keys.joined(separator: ", ")
        let firstPart = "\(keysString) <\(valueSignature)>"
        let paddedUsage = usage.padFront(totalLength: 40 - firstPart.characters.count)
        self.usage = "\(firstPart)\(paddedUsage)"
    }
    
}

public func == (lhs: KeyOption, rhs: KeyOption) -> Bool {
    return lhs.keys == rhs.keys
}

public class Options {
    
    // Keyed by first given flag/key
    var flagOptions: [String: FlagOption] = [:]
    var keyOptions: [String: KeyOption] = [:]
    
    // Keyed by each given flag/key
    var allFlagOptions: [String: FlagOption] = [:]
    var allKeyOptions: [String: KeyOption] = [:]
    
    var unrecognizedOptions: [String] = []
    var keysNotGivenValue: [String] = []
    
    var exitEarlyOptions: [String] = []
    var exitEarly = false
    
    // MARK: - Adding options
    
    /**
        Registers a block to be called on the recognition of certain flags. Usually best
        to pair a single letter flag with a more descriptive flag, e.g. [-a, --all]
    
        - Parameter flags: the flags to be recognized
        - Parameter usage: the usage of these flags, printed in the command usage statement
        - Parameter block: the block to be called upon recognition of the flags
    */
    public func onFlags(flags: [String], usage: String = "", block: FlagOption.FlagBlock?) {
        addFlagOption(flagOption: FlagOption(flags: flags, usage: usage, block: block))
    }
    
    /**
        Registers a block to be called on the recognition of certain keys. Keys have an associated value
        recognized as the argument following the key. Usually best to pair a single letter key with a more 
        descriptive key, e.g. [-m, --message]
    
        - Parameter keys: the keys to be recognized
        - Parameter usage: the usage of these keys, printed in the command usage statement
        - Parameter valueSignature: a name for the associated value, only used in the command usage statement where it
                                    takes the form "-m, --myKey [valueSignature]"
        - Parameter block: the block to be called upon recognition of the keys
    */
    public func onKeys(keys: [String], usage: String = "", valueSignature: String = "value", block: KeyOption.KeyBlock?) {
        addKeyOption(keyOption: KeyOption(keys: keys, usage: usage, valueSignature: valueSignature, block: block))
    }
    
    private func addFlagOption(flagOption: FlagOption) {
        flagOptions[flagOption.flags.first!] = flagOption
        
        flagOption.flags.each { self.allFlagOptions[$0] = flagOption }
    }
    
    private func addKeyOption(keyOption: KeyOption) {
        keyOptions[keyOption.keys.first!] = keyOption
        
        keyOption.keys.each { self.allKeyOptions[$0] = keyOption }
    }
    
    // MARK: - Argument parsing
    
    func recognizeOptionsInArguments(rawArguments: RawArguments) {
        var passedOptions: [String] = []
        rawArguments.unclassifiedArguments().each {(argument) in
            if argument.hasPrefix("-") {
                passedOptions += self.optionsForRawOption(rawOption: argument)
                rawArguments.classifyArgument(argument: argument, type: .Option)
            }
        }
        
        for option in passedOptions {
            if let flagOption = allFlagOptions[option] {
                flagOption.block?(flag: option)
            } else if let keyOption = allKeyOptions[option] {
                if let keyValue = rawArguments.argumentFollowingArgument(argument: option)
                    where !keyValue.hasPrefix("-") {
                        rawArguments.classifyArgument(argument: keyValue, type: .Option)
                        
                        keyOption.block?(key: option, value: keyValue)
                } else {
                    keysNotGivenValue.append(option)
                }
            } else {
                unrecognizedOptions.append(option)
            }
            
            if exitEarlyOptions.contains(option) {
                exitEarly = true
            }
        }
    }
    
    private func optionsForRawOption(rawOption: String) -> [String] {
        if rawOption.hasPrefix("--") {
            return [rawOption]
        }
        
        var chars: [String] = []
        
        for (index, character) in rawOption.characters.enumerated() {
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
            
            message += "\n"
        }
        
        if keysNotGivenValue.count > 0 {
            message += "Required values for options but given none:"
            for option in keysNotGivenValue {
                message += "\n\t\(option)"
            }
            
            message += "\n"
        }
        
        return message
    }
    
}
