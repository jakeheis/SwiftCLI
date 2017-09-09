//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol HelpCommand: Command {
    
    /// Set by CLI to an array of all commands which have been registered
    var availableCommands: [Routable] { get set }
    
    /// Set by CLI to boolean representing whether the CLI description should be printed.
    /// False if router failed, true in all other situations
    var printCLIDescription: Bool { get set }
    
    /// Whether this command should be executed when another commands fails; defaults to false
    var executeOnCommandFailure: Bool { get }
    
}

extension HelpCommand {
    
    public var executeOnCommandFailure: Bool {
        return false
    }
    
}

public class DefaultHelpCommand: HelpCommand {
    
    public let name = "help"
    public let shortDescription = "Prints this help information"
        
    public var availableCommands: [Routable] = []
    public var printCLIDescription = true
    
    public func execute() throws {
        print()
        print("  Usage: \(CLI.name) [command] [flags]")
        
        print()
        print("  Commands:")
        print()
        for command in availableCommands {
            printCommand(command)
        }
        print()
    }
    
    func printCommand(_ command: Routable) {
        let spacing = String(repeating: " ", count: 20 - command.name.characters.count)
        print("  - \(command.name)\(spacing)\(command.shortDescription)")
    }
    
}
