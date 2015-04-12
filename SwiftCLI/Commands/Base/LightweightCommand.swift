//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class LightweightCommand: Command {
    
    public var lightweightCommandName: String = ""
    public var lightweightCommandSignature: String = ""
    public var lightweightCommandShortDescription: String = ""
    public var lightweightCommandShortcut: String? = nil
    public var lightweightExecutionBlock: ExecutionBlock? = nil
    
    public var shouldFailOnUnrecognizedOptions = true
    public var shouldShowHelpOnHFlag = true
    public var printingBehaviorOnUnrecognizedOptions: UnrecognizedOptionsPrintingBehavior = .PrintAll
    
    public init(commandName: String) {
        super.init()
        
        lightweightCommandName = commandName
    }
    
    override public func commandName() -> String  {
        return lightweightCommandName
    }
    
    override public func commandSignature() -> String  {
        return lightweightCommandSignature
    }
    
    override public func commandShortDescription() -> String  {
        return lightweightCommandShortDescription
    }
    
    override public func commandShortcut() -> String?  {
        return lightweightCommandShortcut
    }
    
    // MARK: - Options
    
    public func handleFlags(flags: [String], usage: String = "", block: FlagOption.FlagBlock?) {
        onFlags(flags, usage: usage, block: block)
    }
    
    public func handleKeys(keys: [String], usage: String = "", valueSignature: String = "value", block: KeyOption.KeyBlock?) {
        onKeys(keys, usage: usage, valueSignature: valueSignature, block: block)
    }
    
    override public func showHelpOnHFlag() -> Bool {
        return shouldShowHelpOnHFlag
    }
    
    override public func unrecognizedOptionsPrintingBehavior() -> UnrecognizedOptionsPrintingBehavior {
        return printingBehaviorOnUnrecognizedOptions
    }
    
    override public func failOnUnrecognizedOptions() -> Bool  {
        return shouldFailOnUnrecognizedOptions
    }
    
    // MARK: - Execution
    
    public typealias ExecutionBlock = (arguments: CommandArguments, options: Options) -> ExecutionResult

    override public func execute() -> ExecutionResult {
        return lightweightExecutionBlock!(arguments: arguments, options: options)
    }
    
}

