//
//  Extensions.swift
//  Example
//
//  Created by Jake Heiser on 4/1/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation

extension String {
    
    func padFront(#totalLength: Int) -> String {
        var spacing = ""
        for _ in 0...totalLength {
            spacing += " "
        }
        
        return "\(spacing)\(self)"
    }
    
    func trimEndsByLength(trimLength: Int) -> String {
        let firstIndex = advance(startIndex, trimLength)
        let lastIndex = advance(endIndex, -trimLength)
        return substringWithRange(Range(start: firstIndex, end: lastIndex))
    }
    
}

extension Array {
    
    func each(block: (object: T) -> ()) {
        for object in self {
            block(object: object)
        }
    }
    
    func eachWithIndex(block: (object: T, index: Int) -> ()) {
        for (index, object) in enumerate(self) {
            block(object: object, index: index)
        }
    }
    
}