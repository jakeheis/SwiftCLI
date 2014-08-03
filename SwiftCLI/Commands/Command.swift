//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

enum UnhandledOptionsPrintingBehavior {
    case PrintNone
    case PrintOnlyUnrecognizedOptions
    case PrintOnlyUsage
    case PrintAll
}

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
    
    func commandUsageStatement(commandName: String? = nil) -> String {
        var message = "Usage: \(CLIName)"
        
        let name = commandName ? commandName! : self.commandName()
        if name.utf16Count > 0 {
            message += " \(name)"
        }

        if self.commandSignature().utf16Count > 0 {
            message += " \(self.commandSignature())"
        }
        
        if self.usageStatements.count > 0 {
            message += " [options]\n"
            
            for usage in self.usageStatements {
                message += "\n\(usage)"
            }
            
            message += "\n"
        } else {
            message += "     (no options)\n"
        }
        
        return message
    }
    
    // MARK: - Options
    
    func optionsAccountedFor() -> Bool { // Add final modifier once possible
        self.handleOptions()
        return self.options.allAccountedFor()
    }
    
    func onFlag(flag: String, block: OptionsFlagBlock?, usage: String = "") { // Add final modifier once possible
        let padded = self.padUsageForLength(usage, length: flag.utf16Count);
        self.usageStatements += "\(flag)\(padded)"

        self.options.onFlag(flag, block: block)
    }
    
    func onFlags(flags: [String], block: OptionsFlagBlock?, usage: String = "") { // Add final modifier once possible
        let nsFlags = flags as NSArray
        let comps = nsFlags.componentsJoinedByString(", ")
        let padded = self.padUsageForLength(usage, length: comps.utf16Count);
        self.usageStatements += "\(comps)\(padded)"
        
        self.options.onFlags(flags, block: block)
    }
    
    func onKey(key: String, block: OptionsKeyBlock?, usage: String = "", valueSignature: String = "value") { // Add final modifier once possible
        let firstPart = "\(key) <\(valueSignature)>"
        let padded = self.padUsageForLength(usage, length: firstPart.utf16Count);
        self.usageStatements += "\(firstPart)\(padded)"

        self.options.onKey(key, block: block)
    }
    
    func onKeys(keys: [String], block: OptionsKeyBlock?, usage: String = "", valueSignature: String = "value") { // Add final modifier once possible
        let nsFlags = keys as NSArray
        let comps = nsFlags.componentsJoinedByString(", ")
        let firstPart = "\(comps) <\(valueSignature)>"
        let padded = self.padUsageForLength(usage, length: firstPart.utf16Count);
        self.usageStatements += "\(firstPart)\(padded)"
        
        self.options.onKeys(keys, block: block)
    }
    
    private func padUsageForLength(usage: String, length: Int) -> String {
        var spacing = ""
        for _ in length...40 {
            spacing += " "
        }
        
        return "\(spacing)\(usage)"
    }
    
    func handleOptions() {
        self.onFlags(["-h", "--help"], block: {flag in
            self.showingHelp = true
            
            println(self.commandUsageStatement())
        }, usage: "Show help information for this command")
    }

    func unhandledOptionsPrintingBehavior() -> UnhandledOptionsPrintingBehavior {
        return .PrintAll
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