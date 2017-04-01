//
//  Input.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class Input {
        
    /// Awaits a string of input
    ///
    /// - Parameters:
    ///   - message: message to be printed before accepting input (e.g. "Name: ")
    ///   - secure: boolean defining that input should be hidden
    /// - Returns: input
    public static func awaitInput(message: String?, secure: Bool = false) -> String {
        var input: String? = nil
        while input == nil {
            if let message = message {
                var printMessage = message
                if !printMessage.hasSuffix(" ") && !printMessage.hasSuffix("\n") {
                    printMessage += " "
                }
                print(printMessage, terminator: "")
                fflush(stdout)
            }

            if secure {
                if let chars = UnsafePointer<CChar>(getpass("")) {
                    input = String(cString: chars, encoding: .utf8)
                }
            } else {
                input = readLine()
            }
        }

        return input!
    }
    
    /// Awaits a string of valid input; continues accepting input until the given input is determined to be valid
    ///
    /// - Parameters:
    ///   - message: message to be printed before accepting input (e.g. "Name: ")
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: closure evaluating whether the given input was valid
    /// - Returns: input
    public static func awaitInputWithValidation(message: String?, secure: Bool = false, validation: (_ input: String) -> Bool) -> String {
        while (true) {
            let str = awaitInput(message: message, secure: secure)

            if validation(str) {
                return str
            } else {
                print("Invalid input")
            }
        }
    }
    
    /// Awaits a string of convertible input; continues accepting input until the given input is successfully converted
    ///
    /// - Parameters:
    ///   - message: message to be printed before accepting input (e.g. "Name: ")
    ///   - secure: boolean defining that input should be hidden
    ///   - conversion: closure attempting to convert the input to the desired output
    /// - Returns: input
    public static func awaitInputWithConversion<T>(message: String?, secure: Bool = false, conversion: (_ input: String) -> T?) -> T {
        let input = awaitInputWithValidation(message: message, secure: secure) { (input) in
            return conversion(input) != nil
        }
        
        return conversion(input)!
    }
    
    /// Awaits the input of an Int
    ///
    /// - Parameter message: message to be printed before accepting input (e.g. "Name: ")
    /// - Returns: input int
    public static func awaitInt(message: String?) -> Int {
        return awaitInputWithConversion(message: message) { Int($0) }
    }
    
    /// Awaits yes/no input; "y" and "yes" are accepted as yes and "n" and "no" are accepted as no (case insensitive)
    ///
    /// - Parameter message: message to be printed before accepting input (e.g. "Name: ")
    /// - Returns: bool input
    public static func awaitYesNoInput(message: String = "Confirm?") -> Bool {
        return awaitInputWithConversion(message: "\(message) [y/N]: ") {(input) in
            if input.lowercased() == "y" || input.lowercased() == "yes" {
                return true
            } else if input.lowercased() == "n" || input.lowercased() == "no" {
                return false
            }
            
            return nil
        }
    }
    
}
