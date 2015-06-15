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
    
    static let ParsingError = CLIError.Error("The Bakefile could not be parsed")
    static let BakefileNotFoundError = CLIError.Error("The Bakefile could not be found")
    
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

        addDefaultHelpFlag(options)
    }
    
    func execute(arguments arguments: CommandArguments) throws  {
        if let item = arguments.optionalArgument("item") {
            bakeItem(item)
        } else {
            let items = try loadBakefileItems()
            
            for item in items {
                bakeItem(item)
            }
        }
    }
    
    private func loadBakefileItems() throws -> [String] {
        let bakefile = try loadBakefile()
        
        guard let items = bakefile["items"] as? [String] else {
            throw BakeCommand.ParsingError
        }
        
        return items
    }
    
    private func loadBakefile() throws -> NSDictionary {
        guard let data = NSData(contentsOfFile: "./Bakefile") else {
            throw BakeCommand.BakefileNotFoundError
        }
        
        let parsedJSON: AnyObject
        
        do {
            parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        } catch {
            throw BakeCommand.ParsingError
        }
        
        guard let bakefile = parsedJSON as? NSDictionary else {
            throw BakeCommand.ParsingError
        }
        
        return bakefile
    }
    
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
        let bakefile: NSDictionary
        do {
            bakefile = try loadBakefile()
        } catch {
            return nil
        }
        
        guard let customRecipes = bakefile["custom_recipes"] as? [NSDictionary] else {
            return nil
        }
        
        for recipe in customRecipes {
            if recipe["name"] as? String == item {
                return recipe
            }
        }
        
        return nil
    }
}