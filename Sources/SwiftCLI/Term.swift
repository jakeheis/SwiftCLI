//
//  Term.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/14/17.
//

import Foundation

public class Term {
    
    public static let stdout = StdoutStream()
    public static let stderr = StderrStream()

    public static let isTTY = isatty(fileno(Foundation.stdout)) != 0
    
    private init() {}
    
}
