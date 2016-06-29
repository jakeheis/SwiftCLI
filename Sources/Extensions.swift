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
    
    func trimEnds(trimLength: Int) -> String {
        
        let firstIndex = index(startIndex, offsetBy: trimLength)
        let lastIndex = index(endIndex, offsetBy: -trimLength)
        
        return self.substring(with: Range(uncheckedBounds: (lower: firstIndex, upper: lastIndex)))
    }
    
}
