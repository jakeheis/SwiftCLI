//
//  CommandArgumentsTests.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Cocoa
import XCTest

class CommandArgumentsTests: XCTestCase {
    
    var signature: String = ""
    var arguments: [String] = []
    
    // MARK: - Tests
    
    func testEmptySignature() {
        signature = ""
        
        arguments = []
        assertParseResultEquals([:], assertMessage: "Signature parser should return an empty dictionary for empty signature and empty arguments")
        
        arguments = ["arg"]
        assertParseFails("Signature parser should fail for empty signature and some arguments")
    }
    
    func testRequiredArguments() {
        signature = "<req1> <req2>"
        
        arguments = ["arg1"]
        assertParseFails("Signature parser should fail for 2 required arguments and 1 passed argument")
        
        arguments = ["arg1", "arg2"]
        assertParseResultEquals(["req1": "arg1", "req2": "arg2"], assertMessage: "Signature parser should succeed for 2 required arguments and 2 passed arguments")
    }
    
    func testOptionalArguments() {
        signature = "[<opt1>] [<opt2>]"
        
        arguments = []
        assertParseResultEquals([:], assertMessage: "Signature parser should succeed for 2 optional arguments and 0 passed arguments")
        
        arguments = ["arg1"]
        assertParseResultEquals(["opt1": "arg1"], assertMessage: "Signature parser should succeed for 2 optional arguments and 1 passed argument")
        
        arguments = ["arg1", "arg2"]
        assertParseResultEquals(["opt1": "arg1", "opt2": "arg2"], assertMessage: "Signature parser should succeed for 2 optional arguments and 2 passed arguments")
    }
    
    func testExtraneousArguments() {
        arguments = ["arg1", "arg2"]
        
        signature = "<req1>"
        assertParseFails("Signature parser should fail for 1 required argument and 2 passed arguments")
        
        signature = "<op1>"
        assertParseFails("Signature parser should fail for 1 optional argument and 2 passed arguments")
    }
    
    func testNonTerminalWithRequiredArguments() {
        signature = "<req1> <req2> ..."
        
        arguments = ["arg1", "arg2"]
        assertParseResultEquals(["req1": "arg1", "req2": ["arg2"]], assertMessage: "Signature parser should succeed for a non-terminal required argument and 2 passed arguments")
        
        arguments = ["arg1", "arg2", "arg3"]
        assertParseResultEquals(["req1": "arg1", "req2": ["arg2", "arg3"]], assertMessage: "Signature parser should succeed for a non-terminal required argument and 3 passed arguments")
    }
    
    func testNonTerminalWithOptionalArguments() {
        signature = "[<opt1>] [<opt2>] ..."
        
        arguments = ["arg1", "arg2"]
        assertParseResultEquals(["opt1": "arg1", "opt2": ["arg2"]], assertMessage: "Signature parser should succeed for a non-terminal optional argument and 2 passed arguments")
        
        arguments = ["arg1", "arg2", "arg3"]
        assertParseResultEquals(["opt1": "arg1", "opt2": ["arg2", "arg3"]], assertMessage: "Signature parser should succeed for a non-terminal optional argument and 3 passed arguments")
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
        assertParseResultEquals(["req1": "arg1", "req2": "arg2", "opt1": "arg3"], assertMessage: "Signature parser should succeed for combined signature and 3 passed arguments")
        
        arguments = ["arg1", "arg2", "arg3", "arg4"]
        assertParseResultEquals(["req1": "arg1", "req2": "arg2", "opt1": "arg3", "opt2": "arg4"], assertMessage: "Signature parser should succeed for combined signature and 4 passed arguments")
    }
    
    // MARK: - Helpers
    
    private func createCommandArguments() -> Result<CommandArguments, String> {
        let stringArguments = " ".join(arguments)
        let rawArguments = RawArguments(argumentString: "tester \(stringArguments)")
        let commandSignature = CommandSignature(signature)

        return CommandArguments.fromRawArguments(rawArguments, signature: commandSignature)
    }

    private func assertParseResultEquals(expectedKeyedArguments: NSDictionary, assertMessage: String) {
        let commandArguments = createCommandArguments()
        if let keyedArguments = commandArguments.value?.keyedArguments {
            XCTAssertEqual(keyedArguments, expectedKeyedArguments, assertMessage)
        } else {
            XCTFail(assertMessage)
        }
    }
    
    private func assertParseFails(assertMessage: String) {
        let commandArguments = createCommandArguments()
        if commandArguments.isSuccess {
            XCTFail("\(assertMessage); mistakenly passed and returned \(arguments)")
        }
    }
    
}
