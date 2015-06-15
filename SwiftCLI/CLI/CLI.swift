//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class CLI: NSObject {
    
    // MARK: - Information
    
    static var appName = ""
    static var appVersion = "1.0"
    static var appDescription = ""
    
    private static var commands: [CommandType] = []
    
    static var helpCommand: HelpCommand? = HelpCommand()
    static var versionComand: VersionCommand? = VersionCommand()
    static var defaultCommand: CommandType = helpCommand!
    
    static var routerConfig: Router.Config?
    
    // MARK: -
    
    public class func setup(name name: String, version: String = "1.0", description: String = "") {
        appName = name
        appVersion = version
        appDescription = description
    }
    
    // MARK: - Registering commands
    
    public class func registerCommand(command: CommandType) {
        commands.append(command)
    }
    
    public class func registerCommands(commands: [CommandType]) {
        commands.each { self.registerCommand($0) }
    }
    
    public class func registerChainableCommand(commandName commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        registerCommand(chainable)
        return chainable
    }
    
    // MARK: - Go
    
    public class func go() -> CLIResult {
       return goWithArguments(RawArguments())
    }
    
    public class func debugGoWithArgumentString(argumentString: String) -> CLIResult {
        return goWithArguments(RawArguments(argumentString: argumentString))
    }
    
    private class func goWithArguments(arguments: RawArguments) -> CLIResult {
        do {
            let command = try routeCommand(arguments: arguments)
            let arguments = try setupOptionsAndArguments(command, arguments: arguments)
            try command.execute(arguments: arguments)
            
            return CLIResult.Success
        } catch CLIError.Error(let error) {
            printlnError(error)
        } catch CLIError.EmptyError {
            // Do nothing
        } catch CommandSetupError.ExitEarly {
            return CLIResult.Success
        } catch CommandSetupError.UnrecognizedOptions {
            // Do nothing
        } catch _ {
            printlnError("An error occurred")
        }
        
        return CLIResult.Error
    }
    
    // MARK: - Privates
    
    class private func routeCommand(arguments arguments: RawArguments) throws -> CommandType {
        var allCommands = commands
        if let hc = helpCommand {
            hc.allCommands = commands
            allCommands.append(hc)
        }
        if let vc = versionComand {
            allCommands.append(vc)
        }
        
        let router = Router(commands: allCommands, arguments: arguments, defaultCommand: defaultCommand, config: routerConfig)        
        return try router.route()
    }
    
    enum CommandSetupError: ErrorType {
        case ExitEarly
        case UnrecognizedOptions
    }
    
    class private func setupOptionsAndArguments(command: CommandType, arguments: RawArguments) throws -> CommandArguments {
        if let optionCommand = command as? OptionCommandType {
            let options = Options()
          
            optionCommand.setupOptions(options)
            options.recognizeOptionsInArguments(arguments)
            
            if options.exitEarly { // True if -h flag given (show help but exit early before executing command)
                throw CommandSetupError.ExitEarly
            }
            
            if options.misusedOptionsPresent() {
                if let message = CommandMessageGenerator.generateMisusedOptionsStatement(command: optionCommand, options: options) {
                    printlnError(message)
                }
                if optionCommand.failOnUnrecognizedOptions {
                    throw CommandSetupError.UnrecognizedOptions
                }
            }
        }
        
        let commandSignature = CommandSignature(command.commandSignature)
        
        return try CommandArguments.fromRawArguments(arguments, signature: commandSignature)
    }
    
}

// MARK: -

public enum CLIError: ErrorType {
    case Error(String)
    case EmptyError
}

public typealias CLIResult = Int32

extension CLIResult {
    
    static var Success: CLIResult {
        return 0
    }
    
    static var Error: CLIResult {
        return 1
    }
    
}