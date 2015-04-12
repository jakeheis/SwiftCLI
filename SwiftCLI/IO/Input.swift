//
//  Input.swift
//  Example
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class Input {
    
    public class func awaitInput(#message: String?) -> String {
        if let message = message {
            println(message)
        }
        
        let fh = NSFileHandle.fileHandleWithStandardInput()
        var input = NSString(data: fh.availableData, encoding: NSUTF8StringEncoding) as! String
        input = input.substringToIndex(advance(input.endIndex, -1))
        
        return input
    }
    
    public class func awaitInputWithValidation(#message: String?, validation: (input: String) -> Bool) -> String {
        while (true) {
            let str = awaitInput(message: message)
            
            if validation(input: str) {
                return str
            } else {
                println("Invalid input")
            }
        }
    }
    
    public class func awaitInputWithConversion<T>(#message: String?, conversion: (input: String) -> T?) -> T {
        let input = awaitInputWithValidation(message: message) {(input) in
            return conversion(input: input) != nil
        }
        
        return conversion(input: input)!
    }
    
    public class func awaitInt(#message: String?) -> Int {
        return awaitInputWithConversion(message: message) { $0.toInt() }
    }
    
    public class func awaitYesNoInput(message: String = "Confirm?") -> Bool {
        return awaitInputWithConversion(message: "\(message) [y/N]: ") {input in
            if input.lowercaseString == "y" || input.lowercaseString == "yes" {
                return true
            } else if input.lowercaseString == "n" || input.lowercaseString == "no" {
                return false
            }
            
            return nil
        }
    }
    
}