//
//  ArgumentListManipulator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

public protocol _ArgumentListManipulator {
    func manipulate(arguments: ArgumentList)
}

@available(*, deprecated, message: "use a custom ParserResponse instead")
public protocol ArgumentListManipulator: _ArgumentListManipulator {
    func manipulate(arguments: ArgumentList)
}
