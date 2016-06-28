//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class Option {
    
    let options: [String]
    let usage: String
    
    init(options: [String], usage: String, preusage: String? = nil) {
        self.options = options
        
        var optionsString = options.joined(separator: ", ")
        if let preusage = preusage {
            optionsString += " \(preusage)"
        }
        let paddedUsage = usage.padFront(totalLength: 40 - optionsString.characters.count)
        self.usage = "\(optionsString)\(paddedUsage)"
    }
    
}

public class Options {
    
    public typealias FlagBlock = (flag: String) -> ()
    public typealias KeyBlock = (key: String, value: String) -> ()
    
    var options: [Option] = []
    
    var flagBlocks: [String: FlagBlock] = [:]
    var keyBlocks: [String: KeyBlock] = [:]
    
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
    public func add(flags: [String], usage: String = "", block: FlagBlock) {
        options.append(Option(options: flags, usage: usage))
        for flag in flags {
            flagBlocks[flag] = block
        }
    }
    
    /**
        Registers a block to be called on the recognition of certain keys. Keys have an associated value
        recognized as the argument following the key. Usually best to pair a single letter key with a more 
        descriptive key, e.g. [-m, --message]
    
        - Parameter keys: the keys to be recognized
        - Parameter usage: the usage of these keys, printed in the command usage statement
        - Parameter valueSignature: a name for the associated value, only used in the command usage statement where it
                                    takes the form "-m, --myKey <valueSignature>"
        - Parameter block: the block to be called upon recognition of the keys
    */
    public func add(keys: [String], usage: String = "", valueSignature: String = "value", block: KeyBlock) {
        options.append(Option(options: keys, usage: usage, preusage: "<\(valueSignature)>"))
        for key in keys {
            keyBlocks[key] = block
        }
    }
    
    // MARK: - Argument parsing
    
    func recognizeOptions(in rawArguments: RawArguments) {
        let optionArguments = rawArguments.unclassifiedArguments.filter { $0.value.hasPrefix("-") }
        
        for optionArgument in optionArguments {
            optionArgument.classification = .option
            if let flagBlock = flagBlocks[optionArgument.value] {
                flagBlock(flag: optionArgument.value)
            } else if let keyBlock = keyBlocks[optionArgument.value] {
                if let nextArgument = optionArgument.next where nextArgument.isUnclassified && !nextArgument.value.hasPrefix("-") {
                    nextArgument.classification = .option
                    keyBlock(key: optionArgument.value, value: nextArgument.value)
                } else {
                    keysNotGivenValue.append(optionArgument.value)
                }
            } else {
                unrecognizedOptions.append(optionArgument.value)
            }
            
            if exitEarlyOptions.contains(optionArgument.value) {
                exitEarly = true
            }
        }
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
