//
//  Bakefile.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import Cocoa

class Bakefile {
    
    private var contents: NSMutableDictionary = [:]
    
    var path: String = "./Bakefile"
    
    static let NotFoundError = CLIError.Error("The Bakefile could not be found")
    static let ParsingError = CLIError.Error("The Bakefile could not be parsed")
    static let WritingError = CLIError.Error("The Bakefile could not be written to")
    
    class func create(path path: String) throws {
        let startingContents = ["items": []]
        
        let json: NSData
        
        do {
            json = try NSJSONSerialization.dataWithJSONObject(startingContents, options: NSJSONWritingOptions.PrettyPrinted)
        } catch _ {
            throw Bakefile.WritingError
        }
        
        guard json.writeToFile(path, atomically: true) else {
            throw Bakefile.WritingError
        }
    }
    
    init(path: String) throws {
        guard let data = NSData(contentsOfFile: path) else {
            throw Bakefile.NotFoundError
        }
        
        let parsedJSON: AnyObject
        
        do {
            parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        } catch _ {
            throw Bakefile.ParsingError
        }
        
        guard let bakefileContents = parsedJSON.mutableCopy() as? NSMutableDictionary else {
            throw Bakefile.ParsingError
        }
        
        contents = bakefileContents

        self.path = path
    }
    
    func items() throws -> [String] {
        guard let items = contents["items"] as? [String] else {
            throw Bakefile.ParsingError
        }
        
        return items
    }
    
    func customRecipes() throws -> [NSDictionary] {
        guard let customRecipes = contents["custom_recipes"] as? [NSDictionary] else {
            throw Bakefile.ParsingError
        }
        
        return customRecipes
    }

    func addRecipe(recipe: NSDictionary) throws {
        var customRecipes: [NSDictionary] = contents["custom_recipes"] as? [NSDictionary] ?? []
        customRecipes.append(recipe)
        contents["custom_recipes"] = customRecipes
        
        try save()
    }
    
    func save() throws {
        let finalData: NSData
        
        do {
            finalData = try NSJSONSerialization.dataWithJSONObject(contents, options: .PrettyPrinted)
        } catch _ {
            throw Bakefile.WritingError
        }
        
        guard finalData.writeToFile(path, atomically: true) else {
            throw Bakefile.WritingError
        }
        
    }
    
}
