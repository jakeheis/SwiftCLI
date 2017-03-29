//
//  CommandSignature.swift
//  Pods
//
//  Created by Jake Heiser on 3/9/15.
//
//

/// The command signature of a command
public class CommandSignature {
    
    public var required: [Parameter] = []
    public var optional: [OptionalParameter] = []
    public var collected: AnyCollectedParameter?
    
    init(command: Command) {
        for (_, parameter) in command.parameters {
            assert(collected == nil, "The collection operator (...) must come at the end of a command signature")
            if let c = parameter as? AnyCollectedParameter {
                collected = c
            } else if let r = parameter as? Parameter {
                assert(optional.isEmpty, "All required parameters must come before optional parameters")
                required.append(r)
            } else if let o = parameter as? OptionalParameter {
                optional.append(o)
            } else {
                assertionFailure("Unrecognized argument type")
            }
        }
    }

}
