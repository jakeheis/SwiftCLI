//
//  Command.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class Command: NSObject {
    
    var parameters: NSDictionary
    var options: Options
    
    class var command: Command {
        return Command()
    }
    
    init() {
        self.parameters = [:]
        self.options = Options(args: []) // placeholder
        super.init()
    }
    
    func prepForExecution(parameters: NSDictionary, options: Options) {
        self.parameters = parameters
        self.options = options
    }
    
    func handleOptions() -> Bool {
        return self.options.allAccountedFor()
    }
    
    func execute() -> (success: Bool, error: NSError?) {
        return (true, nil)
    }
    
    var commandName: String {
        return "command"
    }
    
    func commandSignature() -> String {
        return ""
    }
    
    var commandShortDescription: String {
        return ""
    }
    
}