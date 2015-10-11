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
    
    func execute(arguments: CommandArguments) throws {
        let bakefile = try Bakefile()
        
        let recipe: [String: AnyObject]
        
        do {
            let name = try Input.awaitInput(message: "Name of your recipe: ")
            let cookTime = try Input.awaitInt(message: "Cook time: ")
            let silently = try Input.awaitYesNoInput(message: "Bake silently?")

            recipe = ["name": name, "cookTime": cookTime, "silently": silently]
        } catch _ {
            throw CLIError.Error("Data should not be piped to the recipe command")
        }
        
        try bakefile.addRecipe(recipe)
    }
   
}
