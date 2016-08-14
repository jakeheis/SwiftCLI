//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public class OptionRegistry {
    
    public typealias FlagBlock = (flag: String) -> ()
    public typealias KeyBlock = (key: String, value: String) -> ()
    
    var options: [Option] = []
    
    var flagBlocks: [String: FlagBlock] = [:]
    var keyBlocks: [String: KeyBlock] = [:]
    
    var exitEarlyOptions: [String] = []
    
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
    
    @available(*, unavailable, renamed: "add(flags:block:)")
    public func onFlags(_ flags: [String], block: FlagBlock?) {}
    
    @available(*, unavailable, renamed: "add(flags:usage:block:)")
    public func onFlags(_ flags: [String], usage: String, block: FlagBlock?) {}
    
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
    
    @available(*, unavailable, renamed: "add(keys:block:)")
    public func onKeys(_ keys: [String], block: KeyBlock?) {}
    
    @available(*, unavailable, renamed: "add(keys:usage:block:)")
    public func onKeys(_ keys: [String], usage: String, block: KeyBlock?) {}
    
    @available(*, unavailable, renamed: "add(keys:valueSignature:block:)")
    public func onKeys(_ keys: [String], valueSignature: String, block: KeyBlock?) {}
    
    @available(*, unavailable, renamed: "add(keys:usage:valueSignature:block:)")
    public func onKeys(_ keys: [String], usage: String, valueSignature: String, block: KeyBlock?) {}
    
}

@available(*, unavailable, renamed: "OptionRegistry")
public typealias Options = OptionRegistry

public class Option {
    
    let options: [String]
    let usage: String
    
    init(options: [String], usage: String, preusage: String? = nil) {
        self.options = options
        
        var optionsString = options.joined(separator: ", ")
        if let preusage = preusage {
            optionsString += " \(preusage)"
        }
        let spacing = String(repeating: " " as Character, count: 40 - optionsString.characters.count)
        self.usage = "\(optionsString)\(spacing)\(usage)"
    }
    
}
