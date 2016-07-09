//
//  Extensions.swift
//  Example
//
//  Created by Jake Heiser on 4/1/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

extension String {
    
    func trimEnds(by trimLength: Int) -> String {
        let firstIndex = index(startIndex, offsetBy: trimLength)
        let lastIndex = index(endIndex, offsetBy: -trimLength)
        
        return substring(with: Range(uncheckedBounds: (lower: firstIndex, upper: lastIndex)))
    }
    
}
