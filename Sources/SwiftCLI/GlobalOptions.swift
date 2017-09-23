//
//  GlobalOptions.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/30/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

@available(*, unavailable, message: "Use myCli.globalOptions instead of a global options source")
public protocol GlobalOptionsSource {
    static var options: [Option] { get }
}
