//
//  RecipeCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class RecipeCommand: Command {
    
    override func commandName() -> String {
        return "recipe"
    }
    
    override func commandShortDescription() -> String {
        return "Creates a recipe interactively"
    }
    
    override func commandSignature() -> String {
        return ""
    }
    
    override func execute() -> CommandResult {
        let data = NSData(contentsOfFile: "./Bakefile")
        if data == nil {
            return .Failure("No Bakefile could be found in the current directory. Run 'baker init' before this command.")
        }
        
        var bakefile = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil)?.mutableCopy() as NSMutableDictionary?
        if bakefile == nil {
            return .Failure("The Bakefile could not be parsed.")
        }
        
        let name = Input.awaitInput(message: "Name of your recipe: ")
        let cookTime = Input.awaitInt(message: "Cook time: ")
        let silently = Input.awaitYesNoInput(message: "Bake silently?")
        
        let recipe = ["name": name, "cookTime": cookTime, "silently": silently]
        
        var customRecipes: [NSDictionary] = bakefile!["custom_recipes"] as? [NSDictionary] ?? []
        customRecipes.append(recipe)
        bakefile!["custom_recipes"] = customRecipes
        
        let finalData = NSJSONSerialization.dataWithJSONObject(bakefile!, options: .PrettyPrinted, error: nil)
        if finalData?.writeToFile("./Bakefile", atomically: true) == false {
            return .Failure("The Bakefile could not be written to.")
        }
        
        return .Success
    }
   
}
