//
//  CommandSignature.swift
//  Pods
//
//  Created by Jake Heiser on 3/9/15.
//
//

/// The command signature of a command
public class CommandSignature {
    
    public var required: [Argument] = []
    public var optional: [OptionalArgument] = []
    public var collected: AnyCollectedArgument?
    
    init(command: Command) {
        for (_, argument) in command.arguments {
            assert(collected == nil, "The collection operator (...) must come at the end of a command signature")
            if let c = argument as? AnyCollectedArgument {
                collected = c
            } else if let r = argument as? Argument {
                assert(optional.isEmpty, "All required parameters must come before optional parameters")
                required.append(r)
            } else if let o = argument as? OptionalArgument {
                optional.append(o)
            } else {
                assertionFailure("Unrecognized argument type")
            }
        }
    }

}
