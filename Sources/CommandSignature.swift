//
//  CommandSignature.swift
//  Pods
//
//  Created by Jake Heiser on 3/9/15.
//
//

import Foundation

class CommandSignature {
    
    var requiredParameters: [String] = []
    var optionalParameters: [String] = []
    var collectRemainingArguments = false
    
    init(_ string: String) {
        let parameters = string.components(separatedBy: " ").filter { !$0.isEmpty }
        
        let requiredRegex = try! NSRegularExpression(pattern: "^<.*>$", options: [])
        let optionalRegex = try! NSRegularExpression(pattern: "^\\[<.*>\\]$", options: [])
        
        for parameter in parameters {
            if parameter == "..." {
                assert(parameter == parameters.last, "The collection operator (...) must come at the end of a command signature.")
                collectRemainingArguments = true
                continue
            }
            
            let parameterRange = NSRange(location: 0, length: parameter.characters.count)
            
            if requiredRegex.numberOfMatches(in: parameter, options: [], range: parameterRange) > 0 {
                assert(optionalParameters.count == 0, "All required parameters must come before any optional parameter.")
                required(parameter: parameter.trimEnds(trimLength: 1))
            } else if optionalRegex.numberOfMatches(in: parameter, options: [], range: parameterRange) > 0 {
                optional(parameter: parameter.trimEnds(trimLength: 2))
            } else {
                assert(false, "Unrecognized parameter format: \(parameter)")
            }
        }
    }
    
    func required(parameter: String) {
        requiredParameters.append(parameter)
    }
    
    func optional(parameter: String) {
        optionalParameters.append(parameter)
    }
    
    var isEmpty: Bool {
        return requiredParameters.isEmpty && optionalParameters.isEmpty
    }

}
