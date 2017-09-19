//
//  GlobalOptions.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/30/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

@available(*, deprecated, message: "Use myCli.globalOptions instead of a global options source")
public protocol GlobalOptionsSource {
    static var options: [Option] { get }
}

@available(*, deprecated, message: "Use myCli.globalOptions instead of a global options source")
public class GlobalOptions {
    
    public static var options: [Option] {
        guard let shared = CLI.shared else {
            fatalError("Use myCli.globalOptions instead of a global options source")
        }
        return shared.globalOptions
    }
    
    public static func source(_ source: GlobalOptionsSource.Type) {
        guard let shared = CLI.shared else {
            fatalError("Use myCli.globalOptions instead of a global options source")
        }
        shared.globalOptions += source.options
    }
    
}
