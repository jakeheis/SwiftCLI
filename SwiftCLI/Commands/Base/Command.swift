//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public protocol CommandType {
    
    var commandName: String { get }
    var commandSignature: String { get }
    var commandShortDescription: String { get }
    var commandShortcut: String? { get }
    
    func execute(arguments arguments: CommandArguments) throws
    
}

public enum CommandError: ErrorType {
    case Error(String)
}

public enum UnrecognizedOptionsPrintingBehavior {
    case PrintNone
    case PrintOnlyUnrecognizedOptions
    case PrintOnlyUsage
    case PrintAll
}

public protocol OptionCommandType: CommandType {
    
    var failOnUnrecognizedOptions: Bool { get }
    var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior { get }
    
    func setupOptions(options: Options)

}

// Default implementations
extension OptionCommandType {
    
    public var failOnUnrecognizedOptions: Bool {
        return true
    }
    
    public var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior {
        return .PrintAll
    }
    
}

// Additional functionality
extension OptionCommandType {
    
    public func addDefaultHelpFlag(options: Options) {
        let helpFlags = ["-h", "--help"]
        
        options.onFlags(helpFlags, usage: "Show help information for this command") {(flag) in
            print(CommandMessageGenerator.generateUsageStatement(command: self, routedName: nil, options: options))
        }
        
        options.exitEarlyOptions += helpFlags
    }
    
}

public class CommandMessageGenerator {
    
    class func generateUsageStatement(command command: CommandType, routedName: String?, options: Options?) -> String {
        var message = "Usage: \(CLI.appName())"
        
        let name = routedName ?? command.commandName
        if !name.isEmpty {
            message += " \(name)"
        }
        
        if !command.commandSignature.isEmpty {
            message += " \(command.commandSignature)"
        }
        
        if let options = options where !options.flagOptions.isEmpty || !options.keyOptions.isEmpty {
            message += " [options]\n"
            
            let allKeys = options.flagOptions.keys.array + options.keyOptions.keys.array
            let sortedKeys = allKeys.sort()
            for key in sortedKeys {
                let usage = options.flagOptions[key]?.usage ?? options.keyOptions[key]?.usage ?? ""
                message += "\n\(usage)"
            }
            
            message += "\n"
        } else {
            message += "     (no options)\n"
        }
        
        return message
    }
    
    class func generateMisusedOptionsStatement(command command: CommandType, options: Options) -> String? {
        guard let optionsCommand = command as? OptionCommandType else {
            return nil
        }
        
        switch optionsCommand.unrecognizedOptionsPrintingBehavior {
        case .PrintNone:
            return nil
        case .PrintOnlyUsage:
            return generateUsageStatement(command: command, routedName: nil, options: options)
        case .PrintOnlyUnrecognizedOptions:
            return options.misusedOptionsMessage()
        case .PrintAll:
            return generateUsageStatement(command: command, routedName: nil, options: options) + "\n" + options.misusedOptionsMessage()
        }
    }
    
}

//public class Command: NSObject {

//    var options: Options = Options()
    
    // MARK: - Command info
    
    /**
    *  The name this command can be invoked with
    *
    *  @return the command name
    */
    
    /**
    *  The signature for this command
    *
    *  @return the command signature
    */
    
    /**
    *  A short description for this command printed by the HelpCommand
    *
    *  @return the short description
    */
    
    /**
    *  A shortcut for this comma
    nd prefixed with "-"; e.g. "-h" for help, "-v" for version
    *
    *  @return the shortcut
    */
    
    /**
    *  The usage statement for this command, including the signature and available options
    *
    *  @param commandName the name used to invoke this command
    *
    *  @return the usage statement
    */
    
    
    // MARK: - Options
    
//    func recognizeOptionsInArguments(arguments: RawArguments) -> Bool {
//        setupExpectedOptions()
//        
//        options.recognizeOptionsInArguments(arguments)
//        
//        if options.misusedOptionsPresent() {
//            if let message = misusedOptionsMessage(arguments: arguments) {
//                printlnError(message)
//            }
//            if failOnUnrecognizedOptions {
//                return false
//            }
//        }
//        
//        return true
//    }
    
    // MARK: Sublcass option config
    
    /**
    *  Method where all onFlag(s) and onKey(s) calls should be made
    */
    
    /**
    *  Describes if this command should print its usage statement when passed the "-h" flag
    *
    *  @return if usage statement should be printed
    */

    /**
    *  The printing behavior of this command when it is passed an unrecognized option
    *
    *  @return the printing behavior
    */
    
    /**
    *  Describes if this command should fail on unrecognized options
    *
    *  @return if command should fail on unrecognized options
    */
    
    // MARK: - Execution
    
//}
