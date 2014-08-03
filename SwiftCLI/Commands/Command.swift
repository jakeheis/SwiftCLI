//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Command: NSObject {
    
    var arguments: NSDictionary
    var options: Options
    
    var usageStatements: [String] = []
    var showingHelp = false
    
    class func command() -> Self {
        return self()
    }
    
    required init() {
        self.arguments = [:]
        self.options = Options(args: []) // placeholder
        super.init()
    }
    
    // MARK: - Command info
    
    func commandName() -> String {
        return "command"
    }
    
    func commandSignature() -> String {
        return ""
    }
    
    func commandShortDescription() -> String {
        return ""
    }
    
    func commandShortcut() -> String? {
        return nil
    }
    
    func commandUsageStatement() -> String {
        var message = "Usage: \(CLIName) \(self.commandName())"

        if self.commandSignature().utf16Count > 0 {
            message += " \(self.commandSignature())"
        }
        
        if self.usageStatements.count > 0 {
            message += " [options]\n"
            
            for usage in self.usageStatements {
                message += "\n\t\(usage)"
            }
            
            message += "\n"
        }
        
        return message
    }
    
    // MARK: - Options
    
    func optionsAccountedFor() -> Bool { // Add final modifier once possible
        self.handleOptions()
        return self.options.allAccountedFor()
    }
    
    func onFlag(flag: String, block: OptionsFlagBlock?, usage: String = "") { // Add final modifier once possible
        self.options.onFlag(flag, block: block)
        
        self.usageStatements += "\(flag)\t\t\(usage)"
    }
    
    func onFlags(flags: [String], block: OptionsFlagBlock?, usage: String = "") { // Add final modifier once possible
        self.options.onFlags(flags, block: block)
        
        let nsFlags = flags as NSArray
        let comps = nsFlags.componentsJoinedByString(", ")
        self.usageStatements += "\(comps)\t\t\(usage)"
    }
    
    func onKey(key: String, block: OptionsKeyBlock?, usage: String = "", valueSignature: String = "value") { // Add final modifier once possible
        self.options.onKey(key, block: block)
        
        self.usageStatements += "\(key) <\(valueSignature)>\t\t\(usage)"
    }
    
    func onKeys(keys: [String], block: OptionsKeyBlock?, usage: String = "", valueSignature: String = "value") { // Add final modifier once possible
        self.options.onKeys(keys, block: block)
        
        let nsFlags = keys as NSArray
        let comps = nsFlags.componentsJoinedByString(", ")
        self.usageStatements += "\(comps) <\(valueSignature)>\t\t\(usage)"
    }
    
    func handleOptions() {
        self.options.onFlags(["-h", "--help"], block: {flag in
            self.showingHelp = true
            
            println(self.commandUsageStatement())
        })
    }

    func failOnUnhandledOptions() -> Bool {
        return true
    }
    
    // MARK: - Execution
    
    func prepForExecution(arguments: NSDictionary, options: Options) {
        self.arguments = arguments
        self.options = options
    }
    
    func execute() -> (success: Bool, error: String?) {
        return (true, nil)
    }
    
}