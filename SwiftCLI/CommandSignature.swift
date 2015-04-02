//
//  CommandSignature.swift
//  Pods
//
//  Created by Jake Heiser on 3/9/15.
//
//

import Cocoa

public class CommandSignature {
    
    var requiredParameters: [String] = []
    var optionalParameters: [String] = []
    var terminatedList = true
    
    init() {
        
    }
    
    init(_ string: String) {
        var parameters = string.componentsSeparatedByString(" ")
        
        let requiredRegex = NSRegularExpression(pattern: "^<.*>$", options: nil, error: nil)
        let optionalRegex = NSRegularExpression(pattern: "^\\[<.*>\\]$", options: nil, error: nil)
        
        for parameter in parameters {
            if parameter == "..." {
                assert(parameter == parameters.last, "The non-terminal parameter must be at the end of a command signature.")
                terminatedList = false
                continue
            }
            
            let parameterRange = NSRange(location: 0, length: count(parameter))
            
            if requiredRegex?.numberOfMatchesInString(parameter, options: nil, range: parameterRange) > 0 {
                assert(optionalParameters.count == 0, "All required parameters must come before any optional parameter.")
                required(trimStringEnds(string: parameter, trimLength: 1))
            } else if optionalRegex?.numberOfMatchesInString(parameter, options: nil, range: parameterRange) > 0 {
                optional(trimStringEnds(string: parameter, trimLength: 2))
            } else {
                assert(false, "Unrecognized parameter format: \(parameter)")
            }
        }
    }
    
    func required(parameter: String) -> CommandSignature {
        requiredParameters.append(parameter)
        return self
    }
    
    func optional(parameter: String) -> CommandSignature {
        optionalParameters.append(parameter)
        return self
    }
    
    var isEmpty: Bool {
        return requiredParameters.isEmpty && optionalParameters.isEmpty
    }
    
    // MARK: - Private helpers
    
    private func trimStringEnds(#string: String, trimLength: Int) -> String {
        let firstIndex = advance(string.startIndex, trimLength)
        let lastIndex = advance(string.endIndex, -trimLength)
        return string.substringWithRange(Range(start: firstIndex, end: lastIndex))
    }

}
