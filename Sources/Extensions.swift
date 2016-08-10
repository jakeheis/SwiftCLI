//
//  Extensions.swift
//  Example
//
//  Created by Jake Heiser on 4/1/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

extension String {
    
    func padFront(totalLength: Int) -> String {
        var spacing = ""
        for _ in 0...totalLength {
            spacing += " "
        }
        
        return "\(spacing)\(self)"
    }
    
    func trimEndsByLength(_ trimLength: Int) -> String {
        let firstIndex = characters.index(startIndex, offsetBy: trimLength)
        let lastIndex = characters.index(endIndex, offsetBy: -trimLength)
        return substring(with: (firstIndex ..< lastIndex))
    }
    
}

extension Array {
    
    func each(_ block: (object: Element) -> ()) {
        for object in self {
            block(object: object)
        }
    }
    
    func eachWithIndex(_ block: (object: Element, index: Int) -> ()) {
        for (index, object) in self.enumerated() {
            block(object: object, index: index)
        }
    }
    
}
