//
//  CommandSignature.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/9/15.
//  Copyright © 2017 jakeheis. All rights reserved.
//

/// The command signature of a command
public class CommandSignature {
    
    public var required: [Parameter] = []
    public var optional: [OptionalParameter] = []
    public var collected: AnyCollectedParameter?
    
    init(command: Command) {
        for (_, parameter) in command.parameters {
            assert(collected == nil, "The collection parameter must be the last parameter in the command")
            if let c = parameter as? AnyCollectedParameter {
                collected = c
            } else if let r = parameter as? Parameter {
                assert(optional.isEmpty, "All required parameters must come before optional parameters")
                required.append(r)
            } else if let o = parameter as? OptionalParameter {
                optional.append(o)
            } else {
                assertionFailure("Unrecognized parameter type")
            }
        }
    }

}
