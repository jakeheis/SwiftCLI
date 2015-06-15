//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

// MARK: Protocols

public protocol CommandType {

    var commandName: String { get }
    var commandSignature: String { get }
    var commandShortDescription: String { get }
    var commandShortcut: String? { get }
    
    func execute(arguments arguments: CommandArguments) throws
    
}

public protocol OptionCommandType: CommandType {
    
    var failOnUnrecognizedOptions: Bool { get }
    var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior { get }
    
    func setupOptions(options: Options)

}

// MARK: Default implementations

extension CommandType {
    
    public var commandShortcut: String? { return nil }
    
}

extension OptionCommandType {
    
    public var failOnUnrecognizedOptions: Bool { return true }
    
    public var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior { return .PrintAll }
    
}

// MARK: Additional functionality

extension OptionCommandType {
    
    public func addDefaultHelpFlag(options: Options) {
        let helpFlags = ["-h", "--help"]
        
        options.onFlags(helpFlags, usage: "Show help information for this command") {(flag) in
            print(CommandMessageGenerator.generateUsageStatement(command: self, routedName: nil, options: options))
        }
        
        options.exitEarlyOptions += helpFlags
    }
    
}

// MARK: Enums

public enum UnrecognizedOptionsPrintingBehavior {
    case PrintNone
    case PrintOnlyUnrecognizedOptions
    case PrintOnlyUsage
    case PrintAll
}
