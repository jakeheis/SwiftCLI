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
    
    override func execute() -> CommandResult  {
        let item = self.arguments["item"] as String?
        if let i = item {
            self.bakeItem(item!)
        } else {
            let data = NSData.dataWithContentsOfFile("./Bakefile", options: nil, error: nil)
            if !data {
                return .Failure("No Bakefile could be found in the current directory")
            }
            
            let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary!
            if !dict {
                return .Failure("The Bakefile could not be parsed")
            }
            
            let items = dict["items"] as [String]
            for item in items {
                self.bakeItem(item)
            }
        }
        
        return .Success
    }
    
    private func bakeItem(item: String) {
        let quicklyStr = self.quickly ? " quickly" : ""
        let toppingStr = self.topping == nil ? "" : " topped with \(self.topping!)"

        println("Baking a \(item)\(quicklyStr)\(toppingStr)")
        
        var cookTime = 4;
        var silently = self.silently
        
        let recipe = self.checkForRecipe(item)
        if let r = recipe {
            cookTime = r["cookTime"] as Int
            silently = r["silently"] as Bool
        }
        
        if self.quickly {
            cookTime = cookTime/2
        }
        
        for _ in 1...cookTime {
            NSThread.sleepForTimeInterval(1)
            if !silently {
                println("...")
            }
        }
        
        println("Your \(item) is now ready!")
    }
    
    private func checkForRecipe(item: String) -> NSDictionary? {
        let data = NSData.dataWithContentsOfFile("./Bakefile", options: nil, error: nil)
        if data == nil {
            return nil
        }
        let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary!
        if dict == nil {
            return nil
        }
        
        let customRecipes = dict["custom_recipes"] as [NSDictionary]
        for recipe in customRecipes {
            if recipe["name"] as String == item {
                return recipe
            }
        }
        
        return nil
    }
}