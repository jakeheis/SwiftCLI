//
//  BakeCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/1/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class BakeCommand: Command {
    
    private var quickly = false
    private var silently = false
    private var topping: String? = nil
    
    override func commandName() -> String  {
        return "bake"
    }
    
    override func commandShortDescription() -> String  {
        return "Bakes the items in the Bakefile"
    }
    
    override func commandSignature() -> String  {
        return "[<item>]"
    }
    
    override func handleOptions()  {
        self.onFlags(["-q", "--quickly"], block: {flag in
            self.quickly = true
        }, usage: "Bake more quickly")
        
        self.onFlag("-s", block: {flag in
            self.silently = true
        }, usage: "Bake silently")
        
        self.onKeys(["-t", "--with-topping"], block: {key, value in
            self.topping = value
        }, usage: "Adds a topping to the baked good", valueSignature: "topping")
        
        super.handleOptions()
    }
    
    override func execute() -> (success: Bool, error: String?)  {
        let item = self.arguments["item"] as String?
        if item {
            self.bakeItem(item!)
        } else {
            let data = NSData.dataWithContentsOfFile("./Bakefile", options: nil, error: nil)
            if !data {
                return (false, "No Bakefile could be found in the current directory")
            }
            
            let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary!
            if !dict {
                return (false, "The Bakefile could not be parsed")
            }
            
            let items = dict["items"] as [String]
            for item in items {
                self.bakeItem(item)
            }
        }
        
        return (true, nil)
    }
    
    func bakeItem(item: String) {
        let quicklyStr = self.quickly ? " quickly" : ""
        let toppingStr = self.topping ? " topped with \(self.topping!)" : ""

        println("Baking a \(item)\(quicklyStr)\(toppingStr)")
        
        for _ in 1...(self.quickly ? 2 : 4) {
            NSThread.sleepForTimeInterval(1)
            if !self.silently {
                println("...")
            }
        }
        
        println("Your \(item) is now ready!")
    }
    
}