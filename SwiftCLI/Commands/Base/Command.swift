//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class Command: NSObject {
    
    public var arguments: CommandArguments = CommandArguments(keyedArguments: [:])
    
    var options: Options = Options()
    
    var showingHelp = false
    
    // MARK: - Command info
    
    /**
    *  The name this command can be invoked with
    *
    *  @return the command name
    */
    public func commandName() -> String {
        assert(false, "Subclasses of Command must override this method")
        return ""
    }
    
    /**
    *  The signature for this command
    *
    *  @return the command signature
    */
    public func commandSignature() -> String {
        return ""
    }
    
    /**
    *  A short description for this command printed by the HelpCommand
    *
    *  @return the short description
    */
    public func commandShortDescription() -> String {
        return ""
    }
    
    /**
    *  A shortcut for this command prefixed with "-"; e.g. "-h" for help, "-v" for version
    *
    *  @return the shortcut
    */
    public func commandShortcut() -> String? {
        return nil
    }
    
    /**
    *  The usage statement for this command, including the signature and available options
    *
    *  @param commandName the name used to invoke this command
    *
    *  @return the usage statement
    */
    public func commandUsageStatement(commandName givenCommandName: String? = nil) -> String {
        var message = "Usage: \(CLI.appName())"
        
        let name = givenCommandName ?? commandName()
        if !name.isEmpty {
            message += " \(name)"
        }

        if !commandSignature().isEmpty {
            message += " \(commandSignature())"
        }
        
        if !options.flagOptions.isEmpty || !options.keyOptions.isEmpty {
            message += " [options]\n"
            
            let allKeys = options.flagOptions.keys.array + options.keyOptions.keys.array
            let sortedKeys = sorted(allKeys)
            for key in allKeys {
                let usage = options.flagOptions[key]?.usage ?? options.keyOptions[key]?.usage ?? ""
                message += "\n\(usage)"
            }
            
            message += "\n"
        } else {
            message += "     (no options)\n"
        }
        
        return message
    }
    
    // MARK: - Options
    
    final func setupExpectedOptions() {
        handleOptions()
        
        if showHelpOnHFlag() {
            onFlags(["-h", "--help"], usage: "Show help information for this command") {(flag) in
                self.showingHelp = true
                
                println(self.commandUsageStatement())
            }
        }
    }
    
    final func recognizeOptionsInArguments(arguments: RawArguments) -> Bool {
        options.recognizeOptionsInArguments(arguments)
        
        if options.misusedOptionsPresent() {
            if let message = misusedOptionsMessage(arguments: arguments) {
                printlnError(message)
            }
            if failOnUnrecognizedOptions() {
                return false
            }
        }
        
        return true
    }
    
    func misusedOptionsMessage(#arguments: RawArguments) -> String? {
        if unrecognizedOptionsPrintingBehavior() == UnrecognizedOptionsPrintingBehavior.PrintNone {
            return nil
        }
        
        var message = ""
        
        if unrecognizedOptionsPrintingBehavior() != .PrintOnlyUsage {
            message += options.misusedOptionsMessage()
            
            if unrecognizedOptionsPrintingBehavior() == .PrintAll {
               message += "\n"
            }
        }
        
        if unrecognizedOptionsPrintingBehavior() != .PrintOnlyUnrecognizedOptions {
            message += commandUsageStatement(commandName: arguments.firstArgumentOfType(.CommandName))
        }
        
        return message
    }
    
    // MARK: On options
    
    public final func onFlag(flag: String, usage: String = "", block: FlagOption.FlagBlock?) {
        onFlags([flag], usage: usage, block: block)
    }
    
    public final func onFlags(flags: [String], usage: String = "", block: FlagOption.FlagBlock?) {
        options.onFlags(flags, usage: usage, block: block)
    }
    
    public final func onKey(key: String, usage: String = "", valueSignature: String = "value", block: KeyOption.KeyBlock?) {
        onKeys([key], usage: usage, valueSignature: valueSignature, block: block)
    }
    
    public final func onKeys(keys: [String], usage: String = "", valueSignature: String = "value", block: KeyOption.KeyBlock?) {
        options.onKeys(keys, usage: usage, valueSignature: valueSignature, block: block)
    }
    
    // MARK: Sublcass option config
    
    /**
    *  Method where all onFlag(s) and onKey(s) calls should be made
    */
    public func handleOptions() {
        
    }
    
    /**
    *  Describes if this command should print its usage statement when passed the "-h" flag
    *
    *  @return if usage statement should be printed
    */
    public func showHelpOnHFlag() -> Bool {
        return true
    }
    
    public enum UnrecognizedOptionsPrintingBehavior {
        case PrintNone
        case PrintOnlyUnrecognizedOptions
        case PrintOnlyUsage
        case PrintAll
    }

    /**
    *  The printing behavior of this command when it is passed an unrecognized option
    *
    *  @return the printing behavior
    */
    public func unrecognizedOptionsPrintingBehavior() -> UnrecognizedOptionsPrintingBehavior {
        return .PrintAll
    }
    
    /**
    *  Describes if this command should fail on unrecognized options
    *
    *  @return if command should fail on unrecognized options
    */
    public func failOnUnrecognizedOptions() -> Bool {
        return true
    }
    
    // MARK: - Execution
    
    public typealias ExecutionResult = Result<(), String>
    
    public func execute() -> ExecutionResult {
        return success()
    }
    
}
