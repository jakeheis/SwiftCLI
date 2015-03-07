//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

typealias CommandExecutionBlock = ((arguments: NSDictionary, options: Options) -> CommandResult)

class LightweightCommand: Command {
    
    var lightweightCommandName: String = ""
    var lightweightCommandSignature: String = ""
    var lightweightCommandShortDescription: String = ""
    var lightweightCommandShortcut: String? = nil
    var lightweightExecutionBlock: CommandExecutionBlock? = nil
    
    var shouldFailOnUnrecognizedOptions = true
    var shouldShowHelpOnHFlag = true
    var printingBehaviorOnUnrecognizedOptions: UnrecognizedOptionsPrintingBehavior = .PrintAll
    private var flagHandlingBlocks: [LightweightCommandFlagOptionHandler] = []
    private var keyHandlingBlocks: [LightweightCommandKeyOptionHandler] = []
    
    init(commandName: String) {
        super.init()
        
        lightweightCommandName = commandName
    }

    override func commandName() -> String  {
        return lightweightCommandName
    }
    
    override func commandSignature() -> String  {
        return lightweightCommandSignature
    }
    
    override func commandShortDescription() -> String  {
        return lightweightCommandShortDescription
    }
    
    override func commandShortcut() -> String?  {
        return lightweightCommandShortcut
    }
    
    // MARK: - Options
    
    func handleFlags(flags: [String], usage: String = "", block: OptionsFlagBlock?) {
        let handler = LightweightCommandFlagOptionHandler(flags: flags, flagBlock: block, usage: usage)
        flagHandlingBlocks.append(handler)
    }
    
    func handleKeys(keys: [String], usage: String = "", valueSignature: String = "value", block: OptionsKeyBlock?) {
        let handler = LightweightCommandKeyOptionHandler(keys: keys, keyBlock: block, usage: usage, valueSignature: valueSignature)
        keyHandlingBlocks.append(handler)
    }
    
    override func handleOptions()  {
        for handlingBlock in flagHandlingBlocks {
            onFlags(handlingBlock.flags, usage: handlingBlock.usage, block: handlingBlock.flagBlock)
        }
        
        for handlingBlock in keyHandlingBlocks {
            onKeys(handlingBlock.keys, usage: handlingBlock.usage, valueSignature: handlingBlock.valueSignature, block: handlingBlock.keyBlock)
        }
    }
    
    override func showHelpOnHFlag() -> Bool {
        return shouldShowHelpOnHFlag
    }
    
    override func unrecognizedOptionsPrintingBehavior() -> UnrecognizedOptionsPrintingBehavior {
        return printingBehaviorOnUnrecognizedOptions
    }
    
    override func failOnUnrecognizedOptions() -> Bool  {
        return shouldFailOnUnrecognizedOptions
    }
    
    // MARK: - Execution

    override func execute() -> CommandResult {
        return lightweightExecutionBlock!(arguments: arguments, options: options)
    }
    
    // MARK: - Option block wrappers
    
    class LightweightCommandFlagOptionHandler {
        let flags: [String]
        let flagBlock: OptionsFlagBlock?
        let usage: String
        
        init(flags: [String], flagBlock: OptionsFlagBlock?, usage: String) {
            self.flags = flags
            self.flagBlock = flagBlock
            self.usage = usage
        }
    }
    
    class LightweightCommandKeyOptionHandler {
        let keys: [String]
        let keyBlock: OptionsKeyBlock?
        let usage: String
        let valueSignature: String
        
        init(keys: [String], keyBlock: OptionsKeyBlock?, usage: String, valueSignature: String) {
            self.keys = keys
            self.keyBlock = keyBlock
            self.usage = usage
            self.valueSignature = valueSignature
        }
    }
}

