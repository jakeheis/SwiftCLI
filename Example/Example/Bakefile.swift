//
//  Bakefile.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import Cocoa

class Bakefile {
    
    var contents: NSDictionary = [:]
    
    enum Error: ErrorType {
        case NotFoundError
        case ParsingError
        case WritingError
    }
    
    convenience init() throws {
        try self.init(path: "./Bakefile")
    }
    
    init(path: String) throws {
        guard let data = NSData(contentsOfFile: path) else {
            throw Error.NotFoundError
        }
        
        let parsedJSON: AnyObject
        
        do {
            parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        } catch _ {
            throw Error.ParsingError
        }
        
        guard let bakefileContents = parsedJSON as? NSDictionary else {
            throw Error.ParsingError
        }
        
        contents = bakefileContents
    }

}
