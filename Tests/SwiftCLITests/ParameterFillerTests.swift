//
//  CommandArgumentsTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class ParameterFillerTests: XCTestCase {
    
    static var allTests : [(String, (ParameterFillerTests) -> () throws -> Void)] {
        return [
            ("testEmptySignature", testEmptySignature),
            ("testRequiredParameters", testRequiredParameters),
            ("testOptionalParameters", testOptionalParameters),
            ("testOptionalParametersWithInheritance", testOptionalParametersWithInheritance),
            ("testExtraneousArguments", testExtraneousArguments),
            ("testCollectedRequiredParameters", testCollectedRequiredParameters),
            ("testCollectedOptionalParameters", testCollectedOptionalParameters),
            ("testCombinedRequiredAndOptionalParameters", testCombinedRequiredAndOptionalParameters),
            ("testEmptyOptionalCollectedParameter", testEmptyOptionalCollectedParameter),
            ("testExpectedMessages", testExpectedMessages)
        ]
    }
    
    private var req1: Req1Cmd { return current as! Req1Cmd }
    private var req2: Req2Cmd { return current as! Req2Cmd }
    private var opt1: Opt1Cmd { return current as! Opt1Cmd }
    private var opt2: Opt2Cmd { return current as! Opt2Cmd }
    private var opt2Inh: Opt2InhCmd { return current as! Opt2InhCmd }
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
    
    func testRequiredParameters() {
        current = Req2Cmd()
        arguments = ["arg1"]
        assertParseFails("Signature parser should fail for 2 required arguments and 1 passed argument")
        
        current = Req2Cmd()
        arguments = ["arg1", "arg2"]
        assertParse(req2.req1.value == "arg1" && req2.req2.value == "arg2",
                    assertMessage: "Signature parser should succeed for 2 required arguments and 2 passed arguments")
        
        current = Req2Cmd()
        arguments = ["arg1", "arg2", "arg3"]
        assertParseFails("Signature parser should fail for 2 required arguments and 3 passed arguments")
    }
    
    func testOptionalParameters() {
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
        
        current = Opt2Cmd()
        arguments = ["arg1", "arg2", "arg3"]
        assertParseFails("Signature parser should fail for 2 optional arguments and 3 passed arguments")
    }
    
    func testOptionalParametersWithInheritance() {
        current = Opt2InhCmd()
        arguments = []
        assertParse(opt2Inh.opt1.value == nil && opt2Inh.opt2.value == nil,
                    assertMessage: "Signature parser should succeed for 2 optional arguments and 0 passed arguments")
        
        current = Opt2InhCmd()
        arguments = ["arg1"]
        assertParse(opt2Inh.opt1.value == "arg1" && opt2Inh.opt2.value == nil,
                    assertMessage: "Signature parser should succeed for 2 optional arguments and 1 passed argument")
        
        current = Opt2InhCmd()
        arguments = ["arg1", "arg2"]
        assertParse(opt2Inh.opt1.value == "arg1" && opt2Inh.opt2.value == "arg2",
                    assertMessage: "Signature parser should succeed for 2 optional arguments and 2 passed arguments")
        
        current = Opt2InhCmd()
        arguments = ["arg1", "arg2", "arg3"]
        assertParse(opt2Inh.opt1.value == "arg1" && opt2Inh.opt2.value == "arg2" && opt2Inh.opt3.value == "arg3",
                    assertMessage: "Signature parser should succeed for 3 optional arguments and 3 passed arguments")
        
        current = Opt2InhCmd()
        arguments = ["arg1", "arg2", "arg3", "arg4"]
        assertParseFails("Signature parser should fail for 3 optional arguments and 4 passed arguments")
    }
    
    func testExtraneousArguments() {
        arguments = ["arg1", "arg2"]
        
        current = Req1Cmd()
        assertParseFails("Signature parser should fail for 1 required argument and 2 passed arguments")
        
        current = Opt1Cmd()
        assertParseFails("Signature parser should fail for 1 optional argument and 2 passed arguments")
    }
    
    func testCollectedRequiredParameters() {
        current = ReqCollectedCmd()
        arguments = []
        assertParseFails("Signature parser should fail for 1 required argument and 0 passed arguments")

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
    
    func testCollectedOptionalParameters() {
        current = Opt2CollectedCmd()
        arguments = []
        assertParse(opt2Collected.opt1.value == nil && opt2Collected.opt2.value == nil,
                    assertMessage: "Signature parser should succeed for a non-terminal optional argument and 2 passed arguments")
        
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
    
    func testCombinedRequiredAndOptionalParameters() {
        current = Req2Opt2Cmd()
        arguments = ["arg1"]
        assertParseFails("Signature parser should fail for 2 required argument and 1 passed arguments")
        
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
        
        current = Req2Opt2Cmd()
        arguments = ["arg1", "arg2", "arg3", "arg4", "arg5"]
        assertParseFails("Signature parser should fail for 2 required arguments, 2 optional arguments and 5 passed arguments")
    }
    
    func testEmptyOptionalCollectedParameter() { // Tests regression
        current = OptCollectedCmd()
        arguments = []
        assertParse(true, assertMessage: "Signature parser should succeed with empty optional collected parameters")
    }
    
    func testExpectedMessages() {
        let filler = DefaultParameterFiller()
        
        var signature = CommandSignature(command: Req2Cmd())
        XCTAssertEqual(filler.wrongArgCount(signature: signature, got: 1).message, "error: command requires exactly 2 arguments, got 1")
        XCTAssertEqual(filler.wrongArgCount(signature: signature, got: 3).message, "error: command requires exactly 2 arguments, got 3")
        
        signature = CommandSignature(command: ReqCollectedCmd())
        XCTAssertEqual(filler.wrongArgCount(signature: signature, got: 0).message, "error: command requires at least 1 argument, got 0")

        signature = CommandSignature(command: Req2CollectedCmd())
        XCTAssertEqual(filler.wrongArgCount(signature: signature, got: 0).message, "error: command requires at least 2 arguments, got 0")
        XCTAssertEqual(filler.wrongArgCount(signature: signature, got: 1).message, "error: command requires at least 2 arguments, got 1")
        
        signature = CommandSignature(command: Req2Opt2Cmd())
        XCTAssertEqual(filler.wrongArgCount(signature: signature, got: 1).message, "error: command requires between 2 and 4 arguments, got 1")
    }
    
    func testParse() throws {
        let cmd = TestCommand()
        let cli = CLI.createTester(commands: [cmd])
        
        let args = ArgumentList(arguments: ["tester", "test", "-s", "favTest", "-t", "3", "SwiftCLI"])
        let path: CommandPath
        do {
            path = try Parse().parse(commandGroup: cli, arguments: args)
        } catch let error {
            print(error)
            XCTFail()
            return
        }
        
        XCTAssertEqual(path.joined(), "tester test")
        XCTAssertTrue(path.command === cmd)
        
        XCTAssertEqual(cmd.testName.value, "favTest")
        XCTAssertEqual(cmd.testerName.value, "SwiftCLI")
        XCTAssertTrue(cmd.silent.value)
        XCTAssertEqual(cmd.times.value, 3)
    }
    
    // MARK: - Helpers
    
    private func parse() throws {
        let stringArguments = arguments.joined(separator: " ")
        let argumentList = ArgumentList(argumentString: "tester \(stringArguments)")
        
        try DefaultParameterFiller().fillParameters(of: CommandSignature(command: current!), with: argumentList)
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
