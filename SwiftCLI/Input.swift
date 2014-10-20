//
//  Input.swift
//  Example
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Input {
    
    class func awaitInput(#message: String?) -> String {
        if let m = message {
            println(m)
        }
        
        let fh = NSFileHandle.fileHandleWithStandardInput()
        var input = NSString(data: fh.availableData, encoding: NSUTF8StringEncoding) as String
        input = input.substringToIndex(advance(input.endIndex, -1))
        
        return input
    }
    
    class func awaitInputWithValidation(#message: String?, validation: (input: String) -> Bool) -> String {
        while (true) {
            let str = self.awaitInput(message: message)
            
            if validation(input: str) {
                return str
            } else {
                println("Invalid input")
            }
        }
    }
    
    class func awaitInputWithConversion(#message: String?, conversion: (input: String) -> AnyObject?) -> AnyObject {
        let input = self.awaitInputWithValidation(message: message) {input in
            return conversion(input: input) != nil
        }
        
        return conversion(input: input)!
    }
    
    class func awaitInt(#message: String?) -> Int {
        return self.awaitInputWithConversion(message: message) { $0.toInt() } as Int
    }
    
    class func awaitYesNoInput(message: String = "Confirm?") -> Bool {
        return self.awaitInputWithConversion(message: "\(message) [y/N]: ") {input in
            if input.lowercaseString == "y" || input.lowercaseString == "yes" {
                return true
            } else if input.lowercaseString == "n" || input.lowercaseString == "no" {
                return false
            }
            
            return nil
        } as Bool
    }
    
}