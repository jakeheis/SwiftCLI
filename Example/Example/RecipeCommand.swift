//
//  RecipeCommand.swift
//  Example
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class RecipeCommand: CommandType {
    
    static let BakefileNotFoundError = CLIError.Error("The Bakefile could not be found")
    static let ParsingError = CLIError.Error("The Bakefile could not be parsed")
    
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
        let bakefile = try Bakefile(path: "./Bakefile")

        
        let name = Input.awaitInput(message: "Name of your recipe: ")
        let cookTime = Input.awaitInt(message: "Cook time: ")
        let silently = Input.awaitYesNoInput(message: "Bake silently?")
        
        let recipe = ["name": name, "cookTime": cookTime, "silently": silently]
        
        try bakefile.addRecipe(recipe)
    }
   
}
