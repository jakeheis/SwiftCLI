//
//  RecipeCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class RecipeCommand: CommandType {
    
    var commandName: String {
        return "recipe"
    }
    
    var commandShortDescription: String {
        return "Creates a recipe interactively"
    }
    
    var commandSignature: String {
        return ""
    }
    
    func execute(arguments arguments: CommandArguments) throws {
        guard let data = NSData(contentsOfFile: "./Bakefile") else {
            throw CommandError.Error("No Bakefile could be found in the current directory. Run 'baker init' before this command.")
        }
        
        var bakefile: NSMutableDictionary
        
        do {
            let JSONBakefile = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            if let mutBakefile = JSONBakefile.mutableCopy() as? NSMutableDictionary {
                bakefile = mutBakefile
            } else {
                throw CommandError.Error("")
            }
        } catch {
            throw CommandError.Error("The Bakefile could not be parsed")
        }
        
        let name = Input.awaitInput(message: "Name of your recipe: ")
        let cookTime = Input.awaitInt(message: "Cook time: ")
        let silently = Input.awaitYesNoInput(message: "Bake silently?")
        
        let recipe = ["name": name, "cookTime": cookTime, "silently": silently]
        
        var customRecipes: [NSDictionary] = bakefile["custom_recipes"] as? [NSDictionary] ?? []
        customRecipes.append(recipe)
        bakefile["custom_recipes"] = customRecipes
        
        do {
            let finalData = try NSJSONSerialization.dataWithJSONObject(bakefile, options: .PrettyPrinted)
            guard finalData.writeToFile("./Bakefile", atomically: true) else {
                throw CommandError.Error("")
            }
        } catch {
            throw CommandError.Error("The Bakefile could not be written to.")
        }
    }
   
}
