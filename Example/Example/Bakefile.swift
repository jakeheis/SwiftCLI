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
    
    var url: NSURL
    
    static let NotFoundError = CLIError.Error("The Bakefile could not be found")
    static let ParsingError = CLIError.Error("The Bakefile could not be parsed")
    static let WritingError = CLIError.Error("The Bakefile could not be written to")
    
    class func create(url url: NSURL) throws {
        let startingContents = ["items": []]
         
        guard let json = try? NSJSONSerialization.dataWithJSONObject(startingContents, options: .PrettyPrinted) else {
            throw Bakefile.WritingError
        }
        
        guard json.writeToURL(url, atomically: true) else {
            throw Bakefile.WritingError
        }
    }
    
    init() throws {
        url = NSURL(fileURLWithPath: "./Bakefile")
        
        guard let data = NSData(contentsOfURL: url) else {
            throw Bakefile.NotFoundError
        }
        
        guard let parsedJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else {
            throw Bakefile.ParsingError
        }
        
        guard let bakefileContents = parsedJSON.mutableCopy() as? NSMutableDictionary else {
            throw Bakefile.ParsingError
        }
        
        contents = bakefileContents
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
        guard let finalData: NSData = try? NSJSONSerialization.dataWithJSONObject(contents, options: .PrettyPrinted) else {
            throw Bakefile.WritingError
        }
        
        guard finalData.writeToURL(url, atomically: true) else {
            throw Bakefile.WritingError
        }
    }
    
}
