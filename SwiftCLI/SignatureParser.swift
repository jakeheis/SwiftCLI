//
//  SignatureParser.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/25/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class SignatureParser {
    
    class func parse(signature: String, parameters: [String]) -> NSDictionary? {
        if signature == "" {
            if parameters.count == 0 {
                return NSDictionary.dictionary()
            } else {
                return nil
            }
        }
        
        var expectedParams = signature.componentsSeparatedByString(" ")
        
        println("par \(parameters) exp \(expectedParams)")
        
        if expectedParams[expectedParams.count-1] == "..." {
            expectedParams.removeLast()
        } else if parameters.count > expectedParams.count {
            return nil
        }
        println("par \(parameters) exp \(expectedParams)")
        if parameters.count < expectedParams.count {
            println("less parameteres than expected \(parameters.count) vs \(expectedParams.count)f")
            return nil
        }
        println("par \(parameters) exp \(expectedParams)")
        var namedParams: NSMutableDictionary = [:]
        
        for i in 0..<expectedParams.count {
            let name = self.sanitizeKey(expectedParams[i])
            
            
            let value = parameters[i]
            
            namedParams[name] = value
        }
        
        println("params \(parameters) expec \(expectedParams)")
        
        if parameters.count > expectedParams.count {
            let name = self.sanitizeKey(expectedParams[expectedParams.count-1])
            var lastArray: [String] = []
            
            lastArray.append(namedParams[name] as String)
            
            println("name \(name) value \(lastArray)")
            
            for i in expectedParams.count..<parameters.count {
                lastArray.append(parameters[i])
            }
            
            namedParams[name] = lastArray
        }
        
        println("returning \(namedParams)")
        
        return namedParams
    }
    
    class func sanitizeKey(key: String) -> String {
        let  arg = key as NSString
        return arg.substringWithRange(NSMakeRange(1, key.utf16Count - 2))
    }
}