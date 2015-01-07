//
//  SignatureParserTests.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Cocoa
import XCTest

class SignatureParserTests: XCTestCase {
    
    var signature: String = ""
    var arguments: [String] = []
    
    // MARK: - Tests
    
    func testEmptySignature() {
        signature = ""
        
        arguments = []
        assertParserReturnsDictionary([:], assertMessage: "Signature parser should return an empty dictionary for empty signature and empty arguments")
        
        arguments = ["arg"]
        assertParserFails("Signature parser should fail for empty signature and some arguments")
    }
    
    func testRequiredArguments() {
        signature = "<req1> <req2>"
        
        arguments = ["arg1"]
        assertParserFails("Signature parser should fail for 2 required arguments and 1 passed argument")
        
        arguments = ["arg1", "arg2"]
        assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2"], assertMessage: "Signature parser should succeed for 2 required arguments and 2 passed arguments")
    }
    
    func testOptionalArguments() {
        signature = "[<opt1>] [<opt2>]"
        
        arguments = []
        assertParserReturnsDictionary([:], assertMessage: "Signature parser should succeed for 2 optional arguments and 0 passed arguments")
        
        arguments = ["arg1"]
        assertParserReturnsDictionary(["opt1": "arg1"], assertMessage: "Signature parser should succeed for 2 optional arguments and 1 passed argument")
        
        arguments = ["arg1", "arg2"]
        assertParserReturnsDictionary(["opt1": "arg1", "opt2": "arg2"], assertMessage: "Signature parser should succeed for 2 optional arguments and 2 passed arguments")
    }
    
    func testExtraneousArguments() {
        arguments = ["arg1", "arg2"]
        
        signature = "<req1>"
        assertParserFails("Signature parser should fail for 1 required argument and 2 passed arguments")
        
        signature = "<op1>"
        assertParserFails("Signature parser should fail for 1 optional argument and 2 passed arguments")
    }
    
    func testNonTerminalWithRequiredArguments() {
        signature = "<req1> <req2> ..."
        
        arguments = ["arg1", "arg2"]
        assertParserReturnsDictionary(["req1": "arg1", "req2": ["arg2"]], assertMessage: "Signature parser should succeed for a non-terminal required argument and 2 passed arguments")
        
        arguments = ["arg1", "arg2", "arg3"]
        assertParserReturnsDictionary(["req1": "arg1", "req2": ["arg2", "arg3"]], assertMessage: "Signature parser should succeed for a non-terminal required argument and 3 passed arguments")
    }
    
    func testNonTerminalWithOptionalArguments() {
        signature = "[<opt1>] [<opt2>] ..."
        
        arguments = ["arg1", "arg2"]
        assertParserReturnsDictionary(["opt1": "arg1", "opt2": ["arg2"]], assertMessage: "Signature parser should succeed for a non-terminal optional argument and 2 passed arguments")
        
        arguments = ["arg1", "arg2", "arg3"]
        assertParserReturnsDictionary(["opt1": "arg1", "opt2": ["arg2", "arg3"]], assertMessage: "Signature parser should succeed for a non-terminal optional argument and 3 passed arguments")
    }
    
    func testParameterPlacement() {
        arguments = []
        
        // Need to find a way to catch assert()
        
//        signature = "<req1> ... <req2>"
//        assertParserFails("Signature parser should fail if non-terminal is not placed at end")
        
//        signature = "<req1> [<opt1>] <req2>"
//        assertParserFails("Signature parser should fail if optional parameter is before required parameter")
    }
    
    func testCombinedRequiredAndOptionalArguments() {
        signature = "<req1> <req2> [<opt1>] [<opt2>]"

        arguments = ["arg1", "arg2", "arg3"]
        assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2", "opt1": "arg3"], assertMessage: "Signature parser should succeed for combined signature and 3 passed arguments")
        
        arguments = ["arg1", "arg2", "arg3", "arg4"]
        assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2", "opt1": "arg3", "opt2": "arg4"], assertMessage: "Signature parser should succeed for combined signature and 4 passed arguments")
    }
    
    // MARK: - Helpers

    private func assertParserReturnsDictionary(returnDictionary: NSDictionary, assertMessage: String) {
        let signatureParser = SignatureParser(signature: signature, arguments: arguments)
        let result = signatureParser.parse()
        switch result.result {
        case let .Success(arguments):
            XCTAssertEqual(arguments, returnDictionary, assertMessage)
        case .Failure:
            XCTFail(assertMessage)
        }
    }
    
    private func assertParserFails(assertMessage: String) {
        let signatureParser = SignatureParser(signature: signature, arguments: arguments)
        let result = signatureParser.parse()
        switch result.result {
        case let .Success(arguments):
            XCTFail("\(assertMessage); mistakenly passed and returned \(arguments)")
        default:
            break
        }
    }
    
}
