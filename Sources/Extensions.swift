//
//  Extensions.swift
//  Example
//
//  Created by Jake Heiser on 4/1/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

extension String {
    
    func padFront(totalLength totalLength: Int) -> String {
        var spacing = ""
        for _ in 0...totalLength {
            spacing += " "
        }
        
        return "\(spacing)\(self)"
    }
    
    func trimEndsByLength(trimLength: Int) -> String {
        let firstIndex = startIndex.advancedBy(trimLength)
        let lastIndex = endIndex.advancedBy(-trimLength)
        return substringWithRange(Range(start: firstIndex, end: lastIndex))
    }
    
}

extension Array {
    
    func each(block: (object: Element) -> ()) {
        for object in self {
            block(object: object)
        }
    }
    
    func eachWithIndex(block: (object: Element, index: Int) -> ()) {
        for (index, object) in self.enumerate() {
            block(object: object, index: index)
        }
    }
    
}