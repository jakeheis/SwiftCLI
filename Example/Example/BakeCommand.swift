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
        onFlags(["-q", "--quickly"], usage: "Bake more quickly") {(flag) in
            self.quickly = true
        }
        
        onFlag("-s", usage: "Bake silently") {(flag) in
            self.silently = true
        }
        
        onKeys(["-t", "--with-topping"], usage: "Adds a topping to the baked good", valueSignature: "topping") {(key, value) in
            self.topping = value
        }
    }
    
    override func execute() -> ExecutionResult  {
        if let item = arguments.optionalArgument("item") {
            bakeItem(item)
        } else {
            let data = NSData(contentsOfFile: "./Bakefile")
            if data == nil {
                return failure("No Bakefile could be found in the current directory")
            }
            
            if  let data = data,
                let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary,
                let items = dict["items"] as? [String] {
                
                for item in items {
                    bakeItem(item)
                }
            } else {
                return failure("The Bakefile could not be parsed")
            }
        }
        
        return success()
    }
    
    private func bakeItem(item: String) {
        let quicklyStr = quickly ? " quickly" : ""
        let toppingStr = topping == nil ? "" : " topped with \(topping!)"

        println("Baking a \(item)\(quicklyStr)\(toppingStr)")
        
        var cookTime = 4
        
        let recipe = checkForRecipe(item)
        if let recipe = recipe {
            cookTime = recipe["cookTime"] as? Int ?? cookTime
            silently = recipe["silently"] as? Bool ?? silently
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
        if let data = NSData(contentsOfFile: "./Bakefile"),
            let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary,
            let customRecipes = dict["custom_recipes"] as? [NSDictionary] {
            
            for recipe in customRecipes {
                if recipe["name"] as? String == item {
                    return recipe
                }
            }
        }

        return nil
    }
}