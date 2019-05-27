//
//  Term.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/14/17.
//

import Foundation

public enum Term {

    public static let isTTY = isatty(fileno(Foundation.stdout)) != 0
    
    public static var stdout: WritableStream = WriteStream.stdout
    public static var stderr: WritableStream = WriteStream.stderr
    public static var stdin: ReadableStream = ReadStream.stdin

}
