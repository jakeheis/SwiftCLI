//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Command: NSObject {
    
    var arguments: NSDictionary
    var options: Options
    
    class func command() -> Self {
        return self()
    }
    
    required init() {
        self.arguments = [:]
        self.options = Options(args: []) // placeholder
        super.init()
    }
    
    func commandName() -> String {
        return "command"
    }
    
    func commandSignature() -> String {
        return ""
    }
    
    func commandShortDescription() -> String {
        return ""
    }
    
    func commandShortcut() -> String? {
        return nil
    }
    
    func prepForExecution(arguments: NSDictionary, options: Options) {
        self.arguments = arguments
        self.options = options
    }
    
    func optionsAccountedFor() -> Bool {
        self.handleOptions()
        return self.options.allAccountedFor()
    }
    
    func handleOptions() {
        
    }
    
    func execute() -> (success: Bool, error: String?) {
        return (true, nil)
    }
    
}