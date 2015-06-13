//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class LightweightCommand: CommandType {
    
//    public var shouldFailOnUnrecognizedOptions = true
//    public var shouldShowHelpOnHFlag = true
//    public var printingBehaviorOnUnrecognizedOptions: UnrecognizedOptionsPrintingBehavior = .PrintAll
    
    public var commandName: String = ""
    public var commandSignature: String = ""
    public var commandShortDescription: String = ""
    public var commandShortcut: String? = nil
    
    public typealias ExecutionBlock = (arguments: CommandArguments) throws -> ()
    
    public var lightweightExecutionBlock: ExecutionBlock? = nil
    
    public init(commandName: String) {
        self.commandName = commandName
    }
    
    // MARK: - Options
    
//    public func handleFlags(flags: [String], usage: String = "", block: FlagOption.FlagBlock?) {
//        onFlags(flags, usage: usage, block: block)
//    }
//    
//    public func handleKeys(keys: [String], usage: String = "", valueSignature: String = "value", block: KeyOption.KeyBlock?) {
//        onKeys(keys, usage: usage, valueSignature: valueSignature, block: block)
//    }
//    
//    override public var showHelpOnHFlag: Bool {
//        return shouldShowHelpOnHFlag
//    }
//    
//    override public var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior {
//        return printingBehaviorOnUnrecognizedOptions
//    }
//    
//    override public var failOnUnrecognizedOptions: Bool  {
//        return shouldFailOnUnrecognizedOptions
//    }
    
    // MARK: - Execution
    
    public func execute(arguments arguments: CommandArguments) throws {
        try lightweightExecutionBlock?(arguments: arguments)
    }
    
}

