//
//  Input.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public class Input {
    
    /// Reads a line of input
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid
    /// - Returns: input
    public static func readLine(prompt: String? = nil, secure: Bool = false, validation: InputReader<String>.Validation? = nil, errorResponse: InputReader<String>.ErrorResponse? = nil) -> String {
        return InputReader<String>(prompt: prompt, secure: secure, validation: validation, errorResponse: errorResponse).read()
    }
    
    /// Reads a line of input from stdin
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid
    /// - Returns: input
    public static func readInt(prompt: String? = nil, secure: Bool = false, validation: InputReader<Int>.Validation? = nil, errorResponse: InputReader<Int>.ErrorResponse? = nil) -> Int {
        return InputReader<Int>(prompt: prompt, secure: secure, validation: validation, errorResponse: errorResponse).read()
    }
    
    /// Reads a double from stdin
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid
    /// - Returns: input
    public static func readDouble(prompt: String? = nil, secure: Bool = false, validation: InputReader<Double>.Validation? = nil, errorResponse: InputReader<Double>.ErrorResponse? = nil) -> Double {
        return InputReader<Double>(prompt: prompt, secure: secure, validation: validation, errorResponse: errorResponse).read()
    }
    
    /// Reads a bool from stdin. "y", "yes", "t", and "true" are accepted as truthy values
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid
    /// - Returns: input
    public static func readBool(prompt: String? = nil, secure: Bool = false, validation: InputReader<Bool>.Validation? = nil, errorResponse: InputReader<Bool>.ErrorResponse? = nil) -> Bool {
        return InputReader<Bool>(prompt: prompt, secure: secure, validation: validation, errorResponse: errorResponse).read()
    }
    
    private init() {}
    
}

// MARK: InputReader

public protocol Inputable {
    static func convert(input: String) -> Self?
}

extension String: Inputable {
    public static func convert(input: String) -> String? { return input }
}

extension Int: Inputable {
    public static func convert(input: String) -> Int? { return Int(input) }
}

extension Double: Inputable {
    public static func convert(input: String) -> Double? { return Double(input) }
}

extension Bool: Inputable {
    public static func convert(input: String) -> Bool? {
        let lowercased = input.lowercased()
        
        if ["y", "yes", "t", "true"].contains(lowercased) { return true }
        if ["n", "no", "f", "false"].contains(lowercased) { return false }
        
        return nil
    }
}

public class InputReader<T: Inputable> {
    
    public typealias Validation = (T) -> Bool
    public typealias ErrorResponse = (_ input: String) -> ()
    
    public let prompt: String?
    public let secure: Bool
    public let validation: Validation?
    public let errorResponse: ErrorResponse?
    
    public init(prompt: String?, secure: Bool, validation: Validation?, errorResponse: ErrorResponse?) {
        self.prompt = prompt
        self.secure = secure
        self.validation = validation
        self.errorResponse = errorResponse
    }
    
    public func read() -> T {
        while true {
            printPrompt()
            
            var possibleInput: String? = nil
            if secure {
                if let chars = UnsafePointer<CChar>(getpass("")) {
                    possibleInput = String(cString: chars, encoding: .utf8)
                }
            } else {
                possibleInput = ReadInput.read()
            }
            
            guard let input = possibleInput else {
                // Eof reached; no way forward
                exit(1)
            }
            
            if let converted = T.convert(input: input), validation?(converted) ?? true {
                return converted
            } else {
                if let errorResponse = errorResponse {
                    errorResponse(input)
                } else {
                    printError("Invalid input")
                }
            }
        }
    }
    
    private func printPrompt() {
        if var prompt = prompt {
            if !prompt.hasSuffix(" ") && !prompt.hasSuffix("\n") {
                prompt += " "
            }
            print(prompt, terminator: "")
            fflush(stdout)
        }
    }
    
}

// MARK: - ReadInput

// Internal struct which enables testing of Input
struct ReadInput {
    static var read: () -> String? = normalRead
    
    static func normalRead() -> String? {
        return readLine()
    }
    
    private init() {}
}
