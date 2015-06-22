//
//  LightweightCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

/// Can be instantiated and configured as a fully functional command rather
/// than manually implementing CommandType. Should only be used for simple commands
public class LightweightCommand: OptionCommandType {
    
    public var commandName: String = ""
    public var commandSignature: String = ""
    public var commandShortDescription: String = ""
    public var commandShortcut: String? = nil
    
    public var failOnUnrecognizedOptions = true
    public var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior = .PrintAll
    
    public typealias ExecutionBlock = (arguments: CommandArguments, configuration: NSDictionary) throws -> ()
    public typealias OptionsSetupBlock = (options: Options, configuration: NSMutableDictionary) -> ()
    
    public var executionBlock: ExecutionBlock? = nil
    public var optionsSetupBlock: OptionsSetupBlock? = nil
    
    var configuration: NSMutableDictionary = [:]
    
    public init(commandName: String) {
        self.commandName = commandName
    }
    
    public func setupOptions(options: Options) {
        optionsSetupBlock?(options: options, configuration: configuration)
    }
    
    public func execute(arguments arguments: CommandArguments) throws {
        try executionBlock?(arguments: arguments, configuration: configuration)
    }
    
}
