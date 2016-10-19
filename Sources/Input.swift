//
//  Input.swift
//  Example
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class Input {
    
    private static let inputHandle = FileHandle.standardInput
    
    public private(set) static var pipedData: String? = nil
    
    //  MARK: - Public
    
    /**
        Awaits a string of input
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
    */
    public static func awaitInput(message: String?) -> String {
        if let message = message {
            print(message)
        }
        
        var input = String(data: inputHandle.availableData, encoding: String.Encoding.utf8)!
        input = input.substring(to: input.index(input.endIndex, offsetBy: -1))
        
        return input
    }
    
    /**
        Awaits a string of valid input; continues accepting input until the given input is determined to be valid
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
        - Parameter validation: closure evaluating whether the given input was valid
    */
    public static func awaitInputWithValidation(message: String?, validation: (_ input: String) -> Bool) -> String {
        while (true) {
            let str = awaitInput(message: message)
            
            if validation(str) {
                return str
            } else {
                print("Invalid input")
            }
        }
    }
    
    /**
        Awaits a string of convertible input; continues accepting input until the given input is successfully converted
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
        - Parameter conversion: closure attempting to convert the input to the desired output
    */
    public static func awaitInputWithConversion<T>(message: String?, conversion: (_ input: String) -> T?) -> T {
        let input = awaitInputWithValidation(message: message) { (input) in
            return conversion(input) != nil
        }
        
        return conversion(input)!
    }
    
    /**
        Awaits the input of an Int
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
    */
    public static func awaitInt(message: String?) -> Int {
        return awaitInputWithConversion(message: message) { Int($0) }
    }
    
    /**
        Awaits yes/no input; "y" and "yes" are accepted as yes and "n" and "no" are accepted as no (case insensitive)
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
    */
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
    
    // MARK: - Internal
    
    static func checkForPipedData() {
		#if !os(Linux) // Temporary until readabilityHandler is implemented in Swift Foundation
        inputHandle.readabilityHandler = {(inputHandle) in
            pipedData = String(data: inputHandle.availableData, encoding: String.Encoding.utf8)
            inputHandle.readabilityHandler = nil
        }
        let _ = ProcessInfo.processInfo.arguments // For whatever reason, this triggers readabilityHandler for the pipe data
		#endif
    }
    
}
