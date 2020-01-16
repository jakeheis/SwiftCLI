//
//  Input.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/17/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

public enum Input {
    
    /// Reads a line of input
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid; default prints "Invalid input"
    /// - Returns: input
    public static func readLine(prompt: String? = nil, secure: Bool = false, validation: [Validation<String>] = [], errorResponse: InputReader<String>.ErrorResponse? = nil) -> String {
        return readObject(prompt: prompt, secure: secure, validation: validation, errorResponse: errorResponse)
    }
    
    /// Reads a line of input from stdin
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - defaultValue: value to fallback to for empty input; default is nil, meaning an error is shown
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid; default prints "Invalid input"
    /// - Returns: input
    public static func readInt(prompt: String? = nil, defaultValue: Int? = nil, secure: Bool = false, validation: [Validation<Int>] = [], errorResponse: InputReader<Int>.ErrorResponse? = nil) -> Int {
        return readObject(prompt: prompt, secure: secure, validation: validation, errorResponse: errorResponse)
    }
    
    /// Reads a double from stdin
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - defaultValue: value to fallback to for empty input; default is nil, meaning an error is shown
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid; default prints "Invalid input"
    /// - Returns: input
    public static func readDouble(prompt: String? = nil, defaultValue: Double? = nil, secure: Bool = false, validation: [Validation<Double>] = [], errorResponse: InputReader<Double>.ErrorResponse? = nil) -> Double {
        return readObject(prompt: prompt, secure: secure, validation: validation, errorResponse: errorResponse)
    }
    
    /// Reads a bool from stdin. "y", "yes", "t", and "true" are accepted as truthy values
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - defaultValue: value to fallback to for empty input; default is nil, meaning an error is shown
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid; default prints "Invalid input"
    /// - Returns: input
    public static func readBool(prompt: String? = nil, defaultValue: Bool? = nil, secure: Bool = false, validation: [Validation<Bool>] = [], errorResponse: InputReader<Bool>.ErrorResponse? = nil) -> Bool {
        return readObject(prompt: prompt, defaultValue: defaultValue, secure: secure, validation: validation, errorResponse: errorResponse)
    }
    
    /// Reads an object which conforms to ConvertibleFromString from stdin
    ///
    /// - Parameters:
    ///   - prompt: prompt to be printed before accepting input (e.g. "Name: ")
    ///   - defaultValue: value to fallback to for empty input; default is nil, meaning an error is shown
    ///   - secure: boolean defining that input should be hidden
    ///   - validation: predicate defining whether the given input is valid
    ///   - errorResponse: what to do if the input is invalid; default prints "Invalid input"
    /// - Returns: input
    public static func readObject<T: ConvertibleFromString>(prompt: String? = nil, defaultValue: T? = nil, secure: Bool = false, validation: [Validation<T>] = [], errorResponse: InputReader<T>.ErrorResponse? = nil) -> T {
        return InputReader<T>(prompt: prompt, defaultValue: defaultValue, secure: secure, validation: validation, errorResponse: errorResponse).read()
    }
    
}

// MARK: InputReader

public class InputReader<T: ConvertibleFromString> {
    
    public typealias ErrorResponse = (_ input: String, _ resaon: InvalidValueReason) -> ()
    
    public let prompt: String?
    public let defaultValue: T?
    public let secure: Bool
    public let validation: [SwiftCLI.Validation<T>]
    public let errorResponse: ErrorResponse

    public init(prompt: String?, defaultValue: T?, secure: Bool, validation: [SwiftCLI.Validation<T>], errorResponse: ErrorResponse?) {
        self.prompt = prompt
        self.defaultValue = defaultValue
        self.secure = secure
        self.validation = validation
        self.errorResponse = errorResponse ?? { (_, reason) in
            let message = T.messageForInvalidValue(reason: reason, for: nil)
            Term.stderr <<< String(message[message.startIndex]).capitalized + message[message.index(after: message.startIndex)...]
        }
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
                possibleInput = Term.read()
            }
            
            guard let input = possibleInput else {
                // Eof reached; no way forward
                exit(1)
            }

            guard let converted = convert(input: input) else {
                errorResponse(input, .conversionError)
                continue
            }
            
            if let failedValidation = validation.first(where: { $0.validate(converted) == false }) {
                errorResponse(input, .validationError(failedValidation))
                continue
            }
            
            return converted
        }
    }

    private func convert(input: String) -> T? {
        if let defaultValue = defaultValue, input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return defaultValue
        }
        return T(input: input)
    }
    
    private func printPrompt() {
        if var prompt = prompt {
            if !prompt.hasSuffix(" ") && !prompt.hasSuffix("\n") {
                prompt += " "
            }
            Term.stdout.write(prompt)
            fflush(Foundation.stdout)
        }
    }
    
}
