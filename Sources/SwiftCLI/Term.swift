//
//  Term.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/14/17.
//

import Foundation

public class Term {
    
    public static let stdout = WriteStream.stdout
    public static let stderr = WriteStream.stderr

    public static let isTTY = isatty(fileno(Foundation.stdout)) != 0
    
    @discardableResult
    public static func execute(_ cmd: String) -> Int32 {
        return 0
    }
    
    private init() {}
    
}
