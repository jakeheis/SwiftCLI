//
//  CommandArgumentsTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class CommandArgumentsTests: XCTestCase {
    
    static var allTests : [(String, (CommandArgumentsTests) -> () throws -> Void)] {
        return [
            ("testEmptySignature", testEmptySignature),
            ("testRequiredArguments", testRequiredArguments),
            ("testOptionalArguments", testOptionalArguments),
            ("testExtraneousArguments", testExtraneousArguments),
            ("testNonTerminalWithRequiredArguments", testNonTerminalWithRequiredArguments),
            ("testNonTerminalWithOptionalArguments", testNonTerminalWithOptionalArguments),
            ("testParameterPlacement", testParameterPlacement),
            ("testCombinedRequiredAndOptionalArguments", testCombinedRequiredAndOptionalArguments),
            ("testEmptyOptionalCollectedParameter", testEmptyOptionalCollectedParameter),
            ("testQuotedArguments", testQuotedArguments)
        ]
    }
    
    private var req1: Req1Cmd { return current as! Req1Cmd }
    private var req2: Req2Cmd { return current as! Req2Cmd }
    private var opt1: Opt1Cmd { return current as! Opt1Cmd }
    private var opt2: Opt2Cmd { return current as! Opt2Cmd }
    private var reqCollected: ReqCollectedCmd{ return current as! ReqCollectedCmd }
    private var optCollected: OptCollectedCmd { return current as! OptCollectedCmd }
    private var req2Collected: Req2CollectedCmd{ return current as! Req2CollectedCmd }
    private var opt2Collected: Opt2CollectedCmd { return current as! Opt2CollectedCmd }
    private var req2Opt2: Req2Opt2Cmd { return current as! Req2Opt2Cmd }
    
    var current: Command? = nil
    var arguments: [String] = []
    
    // MARK: - Tests
    
    func testEmptySignature() {
        current = EmptyCmd()
        arguments = []
        assertParse(true, assertMessage: "Signature parser should return an empty dictionary for empty signature and empty arguments")
        
        current = EmptyCmd()
        arguments = ["arg"]
        assertParseFails("Signature parser should fail for empty signature and some arguments")
    }
    
    func testRequiredArguments() {
        current = Req2Cmd()
        arguments = ["arg1"]
        assertParseFails("Signature parser should fail for 2 required arguments and 1 passed argument")
        
        current = Req2Cmd()
        arguments = ["arg1", "arg2"]
        assertParse(req2.req1.value == "arg1" && req2.req2.value == "arg2",
                    assertMessage: "Signature parser should succeed for 2 required arguments and 2 passed arguments")
    }
    
    func testOptionalArguments() {
        current = Opt2Cmd()
        arguments = []
        assertParse(opt2.opt1.value == nil && opt2.opt2.value == nil,
                    assertMessage: "Signature parser should succeed for 2 optional arguments and 0 passed arguments")
        
        current = Opt2Cmd()
        arguments = ["arg1"]
        assertParse(opt2.opt1.value == "arg1" && opt2.opt2.value == nil,
                    assertMessage: "Signature parser should succeed for 2 optional arguments and 1 passed argument")
        
        current = Opt2Cmd()
        arguments = ["arg1", "arg2"]
        assertParse(opt2.opt1.value == "arg1" && opt2.opt2.value == "arg2",
                    assertMessage: "Signature parser should succeed for 2 optional arguments and 2 passed arguments")
    }
    
    func testExtraneousArguments() {
        arguments = ["arg1", "arg2"]
        
        current = Req1Cmd()
        assertParseFails("Signature parser should fail for 1 required argument and 2 passed arguments")
        
        current = Opt1Cmd()
        assertParseFails("Signature parser should fail for 1 optional argument and 2 passed arguments")
    }
    
    func testNonTerminalWithRequiredArguments() {
        current = Req2CollectedCmd()
        arguments = ["arg1"]
        assertParseFails("Signature parser should fail for 2 required argument and 1 passed arguments")
        
        current = Req2CollectedCmd()
        arguments = ["arg1", "arg2"]
        assertParse(req2Collected.req1.value == "arg1" && req2Collected.req2.value == ["arg2"],
                    assertMessage: "Signature parser should succeed for a non-terminal required argument and 2 passed arguments")
        
        current = Req2CollectedCmd()
        arguments = ["arg1", "arg2", "arg3"]
        assertParse(req2Collected.req1.value == "arg1" && req2Collected.req2.value == ["arg2", "arg3"],
                    assertMessage: "Signature parser should succeed for a non-terminal required argument and 3 passed arguments")
    }
    
    func testNonTerminalWithOptionalArguments() {
        current = Opt2CollectedCmd()
        arguments = ["arg1"]
        assertParse(opt2Collected.opt1.value == "arg1" && opt2Collected.opt2.value == nil,
                    assertMessage: "Signature parser should succeed for a non-terminal optional argument and 2 passed arguments")
        
        current = Opt2CollectedCmd()
        arguments = ["arg1", "arg2"]
        assertParse(opt2Collected.opt1.value == "arg1" && opt2Collected.opt2.value! == ["arg2"],
                    assertMessage: "Signature parser should succeed for a non-terminal optional argument and 2 passed arguments")
        
        current = Opt2CollectedCmd()
        arguments = ["arg1", "arg2", "arg3"]
        assertParse(opt2Collected.opt1.value == "arg1" && opt2Collected.opt2.value! == ["arg2", "arg3"],
                    assertMessage: "Signature parser should succeed for a non-terminal optional argument and 3 passed arguments")
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
        current = Req2Opt2Cmd()
        arguments = ["arg1", "arg2"]
        assertParse(
            req2Opt2.req1.value == "arg1" && req2Opt2.req2.value == "arg2" &&
            req2Opt2.opt1.value == nil && req2Opt2.opt2.value == nil,
            assertMessage: "Signature parser should succeed for combined signature and 3 passed arguments")
        
        current = Req2Opt2Cmd()
        arguments = ["arg1", "arg2", "arg3"]
        assertParse(
            req2Opt2.req1.value == "arg1" && req2Opt2.req2.value == "arg2" &&
            req2Opt2.opt1.value == "arg3" && req2Opt2.opt2.value == nil,
            assertMessage: "Signature parser should succeed for combined signature and 3 passed arguments")
        
        current = Req2Opt2Cmd()
        arguments = ["arg1", "arg2", "arg3", "arg4"]
        assertParse(
            req2Opt2.req1.value == "arg1" && req2Opt2.req2.value == "arg2" &&
            req2Opt2.opt1.value == "arg3" && req2Opt2.opt2.value == "arg4",
            assertMessage: "Signature parser should succeed for combined signature and 4 passed arguments")
    }
    
    func testEmptyOptionalCollectedParameter() { // Tests regression
        current = OptCollectedCmd()
        arguments = []
        assertParse(true, assertMessage: "Signature parser should succeed with empty optional collected parameters")
    }
    
    func testQuotedArguments() {
        current = Req2Cmd()
        arguments = ["\"hi\" \"hello\""]
        assertParse(req2.req1.value == "hi" && req2.req2.value == "hello",
                    assertMessage: "Signature parser should succeed with a two quoted arguments with one word")
        
        current = Req1Cmd()
        arguments = ["\"hi hello\""]
        assertParse(req1.req1.value == "hi hello",
                    assertMessage: "Signature parser should succeed with a single quoted argument with two words")
        
        current = Req2Cmd()
        arguments = ["\"hi hello\""]
        assertParseFails("Signature parser should fail when one quoted argument given when two necessary")
    }
    
    // MARK: - Helpers
    
    private func parse() throws {
        let stringArguments = arguments.joined(separator: " ")
        let argumentList = ArgumentList(argumentString: "tester \(stringArguments)")
        
        try CLI.commandArgumentParser.parse(arguments: argumentList, for: current!)
    }

    private func assertParse(_ test: @autoclosure () -> Bool, assertMessage: String) {
        do {
            try parse()
            
            XCTAssert(test(), assertMessage)
        } catch {
            XCTFail(assertMessage)
        }
    }
    
    private func assertParseFails(_ assertMessage: String) {
        do {
            try parse()
            XCTFail("\(assertMessage); mistakenly passed and returned \(arguments)")
        } catch {}
    }
    
}

private class EmptyCmd: Command {
    let name = "req"
    let shortDescription = ""
    func execute() throws {}
}

private class Req1Cmd: EmptyCmd {
    let req1 = Argument()
}

private class Opt1Cmd: EmptyCmd {
    let opt1 = OptionalArgument()
}

private class Req2Cmd: EmptyCmd {
    let req1 = Argument()
    let req2 = Argument()
}

private class Opt2Cmd: EmptyCmd {
    let opt1 = OptionalArgument()
    let opt2 = OptionalArgument()
}

private class ReqCollectedCmd: EmptyCmd {
    let req1 = CollectedArgument()
}

private class OptCollectedCmd: EmptyCmd {
    let opt1 = OptionalCollectedArgument()
}

private class Req2CollectedCmd: EmptyCmd {
    let req1 = Argument()
    let req2 = CollectedArgument()
}

private class Opt2CollectedCmd: EmptyCmd {
    let opt1 = OptionalArgument()
    let opt2 = OptionalCollectedArgument()
}

private class Req2Opt2Cmd: EmptyCmd {
    let req1 = Argument()
    let req2 = Argument()
    let opt1 = OptionalArgument()
    let opt2 = OptionalArgument()
}
