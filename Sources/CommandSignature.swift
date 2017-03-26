//
//  CommandSignature.swift
//  Pods
//
//  Created by Jake Heiser on 3/9/15.
//
//

import Foundation

public class CommandSignature {

    public var required: [Arg] = []
    public var optional: [Arg] = []
    public var collected: Arg?
    
    public var signature: String = ""
    //public var collectRemainingArguments = false

    init(command: Command) {
        var components: [String] = []
        let mirror = Mirror(reflecting: command)
        for obj in mirror.children {
            guard let label = obj.label else {
                continue
            }
            if let argument = obj.value as? Arg {
                if argument.collected {
                    collected = argument
                } else if argument.required {
                    required.append(argument)
                } else {
                    optional.append(argument)
                }
                components.append(argument.signature(for: label))
            }
        }
        signature = components.joined(separator: " ")
    }

    /*init(_ string: String) {
        let parameters = string.components(separatedBy: " ").filter { !$0.isEmpty }

        let requiredRegex = try! Regex(pattern: "^<.*>$", options: [])
        let optionalRegex = try! Regex(pattern: "^\\[<.*>\\]$", options: [])

        for parameter in parameters {
            if parameter == "..." {
                assert(parameter == parameters.last, "The collection operator (...) must come at the end of a command signature.")
                collectRemainingArguments = true
                continue
            }

            let parameterRange = NSRange(location: 0, length: parameter.characters.count)

            if requiredRegex.numberOfMatches(in: parameter, options: [], range: parameterRange) > 0 {
                assert(optionalParameters.count == 0, "All required parameters must come before any optional parameter.")
                required(parameter: parameter.trimEnds(by: 1))
            } else if optionalRegex.numberOfMatches(in: parameter, options: [], range: parameterRange) > 0 {
                optional(parameter: parameter.trimEnds(by: 2))
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
    }*/

}
