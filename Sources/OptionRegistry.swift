//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

internal class OptionGroup: Hashable, Equatable {
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: OptionGroup, rhs: OptionGroup) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public var name: String
    public var required: Bool
    public var conflicting: Bool
    
    public init(name: String, required: Bool = false, conflicting: Bool = true) {
        self.hashValue = name.hashValue
        self.name = name
        self.required = required
        self.conflicting = conflicting
    }
    

}

public class OptionRegistry {
    
    public typealias FlagBlock = () -> ()
    public typealias KeyBlock = (_ value: String) -> ()
    
    private(set) public var options: [Option] = []
    internal var groups: Set<OptionGroup> = [OptionGroup(name:"options",required:false,conflicting:false)]

    internal var requiredOptionGroups: [Option] {
        var groupedRequiredOptions: [Option] = []
        var groupedOptionStrings: [String] = []
        var requiredOptions = options.filter() { $0.required == true }

        for group in (groups.filter() {$0.required == true}) {
            let groupName: String = group.name
            let groupOptions = requiredOptions.filter() { $0.group == groupName }
            groupedOptionStrings = groupOptions.flatMap {
                (optionValue) -> [String] in
                let value = optionValue.options
                return value
            }
            groupedRequiredOptions.append(Option(options:groupedOptionStrings,usage:"",required:true,group:groupName))
        }
        return groupedRequiredOptions
    }
    internal var maxSpacing: Int {
        var tempMaxLength: Int = 40
        for group in groups {
            let groupName: String = group.name
            let groupOptions = options.filter() { $0.group == groupName }
            for groupOption in groupOptions {
            
                let length = (groupOption.usage.components(separatedBy: "__SPACING_PLACEHOLDER__")[0]).characters.count
                if (length > tempMaxLength) { tempMaxLength = length }
            
            }
        }
        return tempMaxLength
    }
    internal var conflictingOptionGroups: [Option] {
        var groupedConflictingOptions: [Option] = []
        var groupedOptionStrings: [String] = []
        var conflictingOptions = options.filter() { $0.conflicting == true }
        
        for group in (groups.filter() {$0.conflicting == true}) {
            let groupName: String = group.name
            let groupOptions = conflictingOptions.filter() { $0.group == groupName }
            groupedOptionStrings = groupOptions.flatMap {
                (optionValue) -> [String] in
                let value = optionValue.options
                return value
            }
            groupedConflictingOptions.append(Option(options:groupedOptionStrings,usage:"",conflicting:true,group:groupName))
        }
        return groupedConflictingOptions
    }
    private(set) public var flagBlocks: [String: FlagBlock] = [:]
    private(set) public var keyBlocks: [String: KeyBlock] = [:]
    internal(set) public var exitEarlyOptions: [String] = []
    
    // MARK: - Adding options
    
    /**
        Registers a block to be called on the recognition of certain flags. Usually best
        to pair a single letter flag with a more descriptive flag, e.g. [-a, --all]
    
        - Parameter flags: the flags to be recognized
        - Parameter usage: the usage of these flags, printed in the command usage statement
        - Parameter block: the block to be called upon recognition of the flags
    */
    public func addGroup(name: String, required: Bool = false, conflicting: Bool = true) {
        precondition(name != "", "Must specify a group name.")
        precondition(!groups.contains(OptionGroup(name:name)),"Cannot declare a group twice.")
        groups.insert(OptionGroup(name:name, required:required))
    }
    public func add(flags: [String], usage: String = "", group: String = "options", block: @escaping FlagBlock) {
        var required:Bool
        var conflicting: Bool
        precondition(!flags.isEmpty, "At least one flag must be added")
            precondition(groups.contains(OptionGroup(name:group)),"Undefined Group: \(group)")
            if let temp = (groups.first { $0.name == group }) {
                required = temp.required
                conflicting = temp.conflicting
            }
            else { required = false; conflicting = false }
        options.append(Option(options: flags, usage: usage, required:required, conflicting:conflicting, group:group))
        for flag in flags {
            flagBlocks[flag] = block
        }
    }
    
    @available(*, unavailable, renamed: "add(flags:block:)", message: "also, flag block no longer passes flag")
    public func onFlags(_ flags: [String], block: FlagBlock?) {}
    
    @available(*, unavailable, renamed: "add(flags:usage:block:)", message: "also, flag block no longer passes flag")
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
    public func add(keys: [String], usage: String = "", valueSignature: String = "value", group: String = "options", block: @escaping KeyBlock) {
        precondition(!keys.isEmpty, "At least one key must be added")
        var required:Bool
        var conflicting: Bool
        precondition(groups.contains(OptionGroup(name:group)),"Undefined Group: \(group)")
            if let temp = (groups.first { $0.name == group }) {
                required = temp.required
                conflicting = temp.conflicting
            }
            else { required = false; conflicting = false }
        options.append(Option(options: keys, usage: usage, preusage: "<\(valueSignature)>",required:required, conflicting:conflicting, group:group))
        for key in keys {
            keyBlocks[key] = block
        }
    }
    
    public typealias OldKeyBlock = (_ key: String, _ value: String) -> ()
    
    @available(*, unavailable, renamed: "add(keys:block:)", message: "also, key block no longer passes key (only value)")
    public func onKeys(_ keys: [String], block: OldKeyBlock?) {}
    
    @available(*, unavailable, renamed: "add(keys:usage:block:)", message: "also, key block no longer passes key (only value)")
    public func onKeys(_ keys: [String], usage: String, block: OldKeyBlock?) {}
    
    @available(*, unavailable, renamed: "add(keys:valueSignature:block:)", message: "also, key block no longer passes key (only value)")
    public func onKeys(_ keys: [String], valueSignature: String, block: OldKeyBlock?) {}
    
    @available(*, unavailable, renamed: "add(keys:usage:valueSignature:block:)", message: "also, key block no longer passes key (only value)")
    public func onKeys(_ keys: [String], usage: String, valueSignature: String, block: OldKeyBlock?) {}
    
}

@available(*, unavailable, renamed: "OptionRegistry")
public typealias Options = OptionRegistry

public class Option {
    
    public let required: Bool
    public let conflicting: Bool
    public let group: String
    public let options: [String]
    public let usage: String
    
    init(options: [String], usage: String, preusage: String? = nil, required: Bool = false, conflicting: Bool = false, group: String = "options") {
        self.options = options
        self.required = required
        self.group = group
        self.conflicting = conflicting
        
        var optionsString = options.joined(separator:", ")
        
        if let preusage = preusage {
            optionsString += " \(preusage)"
        }
        self.usage = "\(optionsString)__SPACING_PLACEHOLDER__\(usage)"
    }
    
}
