//
//  CommandSignature.swift
//  Pods
//
//  Created by Jake Heiser on 3/9/15.
//
//

import Foundation

public class CommandSignature {

    public var required: [Argument] = []
    public var optional: [OptionalArgument] = []
    public var collected: CollectedArg?
    
    public var signature: String = ""

    init(command: Command) {
        var components: [String] = []
        let mirror = Mirror(reflecting: command)
        for obj in mirror.children {
            guard let label = obj.label else {
                continue
            }
            if let argument = obj.value as? Arg {
                assert(collected == nil, "The collection operator (...) must come at the end of a command signature")
                if let c = argument as? CollectedArg {
                    collected = c
                } else if let r = argument as? Argument {
                    assert(optional.isEmpty, "All required parameters must come before optional parameters")
                    required.append(r)
                } else if let o = argument as? OptionalArgument {
                    optional.append(o)
                } else {
                    assertionFailure("Unrecognized argument type")
                }
                components.append(argument.signature(for: label))
            }
        }
        signature = components.joined(separator: " ")
    }

}
