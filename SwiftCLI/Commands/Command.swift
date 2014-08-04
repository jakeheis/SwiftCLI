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

class Command {
    
    var arguments: NSDictionary = [:]
    var options: Options = Options()
    
    var usageStatements: [String] = []
    var showingHelp = false
    
    // MARK: - Command info
    
    func commandName() -> String {
        assert(false, "Subclasses of Command must override this method")
        return ""
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
        var message = "Usage: \(CLI.appName())"
        
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
    
    func optionsAccountedFor() -> Bool { // TODO: Add final modifier once possible
        self.handleOptions()
        
        if self.showHelpOnHFlag() {
            self.onFlags(["-h", "--help"], block: {flag in
                self.showingHelp = true
                
                println(self.commandUsageStatement())
            }, usage: "Show help information for this command")
        }
        
        return self.options.allAccountedFor()
    }
    
    // MARK: On options
    
    func onFlag(flag: String, block: OptionsFlagBlock?, usage: String = "") { // TODO: Add final modifier once possible
        self.onFlags([flag], block: block, usage: usage)
    }
    
    func onFlags(flags: [String], block: OptionsFlagBlock?, usage: String = "") { // TODO: Add final modifier once possible
        let comps = ", ".join(flags)
        let padded = self.padUsageForLength(usage, length: comps.utf16Count);
        self.usageStatements += "\(comps)\(padded)"
        
        self.options.onFlags(flags, block: block)
    }
    
    func onKey(key: String, block: OptionsKeyBlock?, usage: String = "", valueSignature: String = "value") { // TODO: Add final modifier once possible
        self.onKeys([key], block: block, usage: usage, valueSignature: valueSignature)
    }
    
    func onKeys(keys: [String], block: OptionsKeyBlock?, usage: String = "", valueSignature: String = "value") { // TODO: Add final modifier once possible
        let comps = ", ".join(keys)
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
    
    // MARK: Sublcass option config
    
    func showHelpOnHFlag() -> Bool {
        return true
    }
    
    func handleOptions() {
        
    }

    func unhandledOptionsPrintingBehavior() -> UnhandledOptionsPrintingBehavior {
        return .PrintAll
    }
    
    func failOnUnhandledOptions() -> Bool {
        return true
    }
    
    // MARK: - Execution
    
    func execute() -> (success: Bool, error: String?) {
        return (true, nil)
    }
    
}