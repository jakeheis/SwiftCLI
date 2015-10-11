//
//  BakeCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/1/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class BakeCommand: OptionCommandType {
        
    private var quickly = false
    private var silently = false
    private var topping: String? = nil
    
    var commandName: String  {
        return "bake"
    }
    
    var commandSignature: String  {
        return "[<item>]"
    }
    
    var commandShortDescription: String  {
        return "Bakes the items in the Bakefile"
    }
    
    func setupOptions(options: Options) {
        options.onFlags(["-q", "--quickly"], usage: "Bake more quickly") {(flag) in
            self.quickly = true
        }
        
        options.onFlags(["-s", "--silently"], usage: "Bake silently") {(flag) in
            self.silently = true
        }
        
        options.onKeys(["-t", "--with-topping"], usage: "Adds a topping to the baked good", valueSignature: "topping") {(key, value) in
            self.topping = value
        }
    }
    
    func execute(arguments: CommandArguments) throws  {
        if let item = arguments.optionalArgument("item") {
            bakeItem(item)
        } else if let pipedList = Input.pipedData {
            let items = pipedList.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByString(" ")
            for item in items {
                bakeItem(item)
            }
        } else {
            let items = try loadBakefileItems()
            
            for item in items {
                bakeItem(item)
            }
        }
    }
    
    // MARK: - Baking
    
    private func bakeItem(item: String) {
        let quicklyStr = quickly ? " quickly" : ""
        let toppingStr = topping == nil ? "" : " topped with \(topping!)"

        print("Baking a \(item)\(quicklyStr)\(toppingStr)")
        
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
                print("...")
            }
        }
        
        print("Your \(item) is now ready!")
    }
    
    private func checkForRecipe(item: String) -> NSDictionary? {
        do {
            let recipes = try loadBakefileRecipes()
            
            for recipe in recipes {
                if recipe["name"] as? String == item {
                    return recipe
                }
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    // MARK: - Loading
    
    private func loadBakefileItems() throws -> [String] {
        let bakefile = try Bakefile()
        let items = try bakefile.items()
        
        return items
    }
    
    private func loadBakefileRecipes() throws -> [NSDictionary] {
        let bakefile = try Bakefile()
        let recipes = try bakefile.customRecipes()
        
        return recipes
    }
    
}