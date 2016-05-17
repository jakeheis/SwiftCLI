//
//  Input.swift
//  Example
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class Input {
    
    private static let inputHandle = NSFileHandle.standardInput()
    
    public private(set) static var pipedData: String? = nil
    
    static let PipeUserInputOverlapError = CLIError.Error("Data should not be both piped and input")
    
    //  MARK: - Public
    
    /**
        Awaits a string of input
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
        - Throws: Input.PipeUserInputOverlapError if the user piped data and this method was called
    */
    public class func awaitInput(message: String?) throws -> String {
        if pipedData != nil {
            throw PipeUserInputOverlapError
        }
        
        if let message = message {
            print(message)
        }
        
        var input = String(data: inputHandle.availableData, encoding: NSUTF8StringEncoding)!
        input = input.substring(to: input.index(input.endIndex, offsetBy: -1))
        
        return input
    }
    
    /**
        Awaits a string of valid input; continues accepting input until the given input is determined to be valid
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
        - Parameter validation: closure evaluating whether the given input was valid
        - Throws: Input.PipeUserInputOverlapError if the user piped data and this method was called
    */
    public class func awaitInputWithValidation(message: String?, validation: (input: String) -> Bool) throws -> String {
        while (true) {
            let str = try awaitInput(message: message)
            
            if validation(input: str) {
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
        - Throws: Input.PipeUserInputOverlapError if the user piped data and this method was called
    */
    public class func awaitInputWithConversion<T>(message: String?, conversion: (input: String) -> T?) throws -> T {
        let input = try awaitInputWithValidation(message: message) {(input) in
            return conversion(input: input) != nil
        }
        
        return conversion(input: input)!
    }
    
    /**
        Awaits the input of an Int
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
        - Throws: Input.PipeUserInputOverlapError if the user piped data and this method was called
    */
    public class func awaitInt(message: String?) throws -> Int {
        return try awaitInputWithConversion(message: message) { Int($0) }
    }
    
    /**
        Awaits yes/no input; "y" and "yes" are accepted as yes and "n" and "no" are accepted as no (case insensitive)
        - Parameter message: message to be printed before accepting input (e.g. "Name: ")
        - Throws: Input.PipeUserInputOverlapError if the user piped data and this method was called
    */
    public class func awaitYesNoInput(message: String = "Confirm?") throws -> Bool {
        return try awaitInputWithConversion(message: "\(message) [y/N]: ") {(input) in
            if input.lowercased() == "y" || input.lowercased() == "yes" {
                return true
            } else if input.lowercased() == "n" || input.lowercased() == "no" {
                return false
            }
            
            return nil
        }
    }
    
    // MARK: - Internal
    
    class func checkForPipedData() {
        inputHandle.readabilityHandler = {(inputHandle) in
            pipedData = String(data: inputHandle.availableData, encoding: NSUTF8StringEncoding)
            inputHandle.readabilityHandler = nil
        }
        NSProcessInfo.processInfo().arguments // For whatever reason, this triggers readabilityHandler for the pipe data
    }
    
}