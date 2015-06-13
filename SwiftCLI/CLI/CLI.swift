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
    
    private struct CLIStatic {
        static var appName = ""
        static var appVersion = "1.0"
        static var appDescription = ""
        
        static var commands: [CommandType] = []
        static var helpCommand: HelpCommand? = HelpCommand()
        static var versionComand: VersionCommand? = VersionCommand()
        static var defaultCommand: CommandType = CLIStatic.helpCommand!
    }
    
    public class func setup(name name: String, version: String = "1.0", description: String = "") {
        CLIStatic.appName = name
        CLIStatic.appVersion = version
        CLIStatic.appDescription = description
    }
    
    public class func appName() -> String {
        return CLIStatic.appName
    }
    
    public class func appDescription() -> String {
        return CLIStatic.appDescription
    }
    
    // MARK: - Registering commands
    
    public class func registerCommand(command: CommandType) {
        CLIStatic.commands.append(command)
    }
    
    public class func registerCommands(commands: [CommandType]) {
        commands.each { self.registerCommand($0) }
    }
    
    public class func registerChainableCommand(commandName commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        registerCommand(chainable)
        return chainable
    }
    
    public class func registerCustomHelpCommand(helpCommand: HelpCommand?) {
        CLIStatic.helpCommand = helpCommand
    }
    
    public class func registerCustomVersionCommand(versionCommand: VersionCommand?) {
        CLIStatic.versionComand = versionCommand
    }
    
    public class func registerDefaultCommand(command: CommandType) {
        CLIStatic.defaultCommand = command
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
        } catch Router.RouterError.CommandNotFound {
            printlnError("Command not found")
        } catch Router.RouterError.ArgumentError {
            printlnError("Router failed")
        } catch CommandSetupError.ExitEarly {
            return CLIResult.Success
        } catch CommandSetupError.UnrecognizedOptions {
            // Do nothing
        } catch CommandArguments.Error.ParsingError(let error) {
            if !error.isEmpty {
                printlnError(error)
            }
        } catch CommandError.Error(let error) {
            if !error.isEmpty {
                printlnError(error)
            }
        } catch {
            printlnError("An error occurred")
        }
        
        return CLIResult.Error
    }
    
    // MARK: - Privates
    
    class private func routeCommand(arguments arguments: RawArguments) throws -> CommandType {
        var allCommands = CLIStatic.commands
        if let hc = CLIStatic.helpCommand {
            hc.allCommands = CLIStatic.commands
            allCommands.append(hc)
        }
        if let vc = CLIStatic.versionComand {
            allCommands.append(vc)
        }
        
        let router = Router(commands: allCommands, arguments: arguments, defaultCommand: CLIStatic.defaultCommand)
        
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
            
            if options.exitEarly {
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

public typealias CLIResult = Int32

extension CLIResult {
    
    static var Success: CLIResult {
        return 0
    }
    
    static var Error: CLIResult {
        return 1
    }
    
}