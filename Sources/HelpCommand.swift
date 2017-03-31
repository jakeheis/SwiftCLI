//
//  HelpCommand.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

public protocol HelpCommand: Command {
    
    /// Set by CLI to an array of all commands which have been registered
    var availableCommands: [Command] { get set }
    
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
        
    public var availableCommands: [Command] = []
    public var printCLIDescription = true
    
    public func execute() throws {
        if printCLIDescription && !CLI.description.isEmpty {
            print("\(CLI.description)")
            print()
        }
        
        print("Available commands: ")

        for command in availableCommands {
            printCommand(command)
        }
    }
    
    func printCommand(_ command: Command) {
        let spacing = String(repeating: " ", count: 20 - command.name.characters.count)
        print("- \(command.name)\(spacing)\(command.shortDescription)")
    }
    
}
