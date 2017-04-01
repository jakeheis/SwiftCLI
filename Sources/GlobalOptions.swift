//
//  GlobalOptions.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/30/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

public protocol GlobalOptionsSource {
    static var options: [Option] { get }
}

public class GlobalOptions {
    
    public static var options: [Option] = DefaultGlobalOptions.options
    
    public static func source(_ source: GlobalOptionsSource.Type) {
        options += source.options
    }
    
}

// MARK: - Default

struct DefaultGlobalOptions: GlobalOptionsSource {
    static let help = Flag("-h", "--help", usage: "Show help information for this command")
    static var options: [Option] {
        return [help]
    }
}
