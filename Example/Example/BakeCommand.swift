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
        onFlags(["-q", "--quickly"], block: {flag in
            self.quickly = true
        }, usage: "Bake more quickly")
        
        onFlag("-s", block: {flag in
            self.silently = true
        }, usage: "Bake silently")
        
        onKeys(["-t", "--with-topping"], block: {key, value in
            self.topping = value
        }, usage: "Adds a topping to the baked good", valueSignature: "topping")
    }
    
    override func execute() -> CommandResult  {
        let item = arguments["item"] as String?
        if let item = item {
            bakeItem(item)
        } else {
            let data = NSData(contentsOfFile: "./Bakefile")
            if data == nil {
                return .Failure("No Bakefile could be found in the current directory")
            }
            
            let dict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as NSDictionary?
            if dict == nil {
                return .Failure("The Bakefile could not be parsed")
            }
            
            let items = dict!["items"] as [String]
            for item in items {
                bakeItem(item)
            }
        }
        
        return .Success
    }
    
    private func bakeItem(item: String) {
        let quicklyStr = quickly ? " quickly" : ""
        let toppingStr = topping == nil ? "" : " topped with \(topping!)"

        println("Baking a \(item)\(quicklyStr)\(toppingStr)")
        
        var cookTime = 4
        
        let recipe = checkForRecipe(item)
        if let recipe = recipe {
            cookTime = recipe["cookTime"] as Int
            silently = recipe["silently"] as Bool
        }
        
        if quickly {
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
        let data = NSData(contentsOfFile: "./Bakefile")
        if data == nil {
            return nil
        }
        let dict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as NSDictionary?
        if dict == nil {
            return nil
        }
        
        let customRecipes = dict!["custom_recipes"] as [NSDictionary]
        for recipe in customRecipes {
            if recipe["name"] as String == item {
                return recipe
            }
        }
        
        return nil
    }
}