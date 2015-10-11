//
//  Input.swift
//  Example
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class Input {
    
    private static let inputHandle = NSFileHandle.fileHandleWithStandardInput()
    
    private(set) static var pipedData: String? = nil
    
    static let PipeUserInputOverlapError = CLIError.Error("Data should not be both piped and input")
    
    //  MARK: - Public
    
    public class func awaitInput(message message: String?) throws -> String {
        if pipedData != nil {
            throw PipeUserInputOverlapError
        }
        
        if let message = message {
            print(message)
        }
        
        var input = String(data: inputHandle.availableData, encoding: NSUTF8StringEncoding)!
        input = input.substringToIndex(input.endIndex.advancedBy(-1))
        
        return input
    }
    
    public class func awaitInputWithValidation(message message: String?, validation: (input: String) -> Bool) throws -> String {
        while (true) {
            let str = try awaitInput(message: message)
            
            if validation(input: str) {
                return str
            } else {
                print("Invalid input")
            }
        }
    }
    
    public class func awaitInputWithConversion<T>(message message: String?, conversion: (input: String) -> T?) throws -> T {
        let input = try awaitInputWithValidation(message: message) {(input) in
            return conversion(input: input) != nil
        }
        
        return conversion(input: input)!
    }
    
    public class func awaitInt(message message: String?) throws -> Int {
        return try awaitInputWithConversion(message: message) { Int($0) }
    }
    
    public class func awaitYesNoInput(message message: String = "Confirm?") throws -> Bool {
        return try awaitInputWithConversion(message: "\(message) [y/N]: ") {(input) in
            if input.lowercaseString == "y" || input.lowercaseString == "yes" {
                return true
            } else if input.lowercaseString == "n" || input.lowercaseString == "no" {
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