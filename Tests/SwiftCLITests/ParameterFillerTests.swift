//
//  CommandArgumentsTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

extension ParserTests {
    
//    static var allTests : [(String, (ParameterFillerTests) -> () throws -> Void)] {
//        return [
//            ("testEmptySignature", testEmptySignature),
//            ("testRequiredParameters", testRequiredParameters),
//            ("testOptionalParameters", testOptionalParameters),
//            ("testOptionalParametersWithInheritance", testOptionalParametersWithInheritance),
//            ("testExtraneousArguments", testExtraneousArguments),
//            ("testCollectedRequiredParameters", testCollectedRequiredParameters),
//            ("testCollectedOptionalParameters", testCollectedOptionalParameters),
//            ("testCombinedRequiredAndOptionalParameters", testCombinedRequiredAndOptionalParameters),
//            ("testEmptyOptionalCollectedParameter", testEmptyOptionalCollectedParameter),
//            ("testExpectedMessages", testExpectedMessages)
//        ]
//    }
    
    // MARK: - Tests
    
    @discardableResult
    func parse<T: Command>(command: T, args: [String]) throws -> T {
        let cli = CLI.createTester(commands: [command])
        let arguments = ArgumentList(arguments: ["tester", "cmd"] + args)
        _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        return command
    }
    
    func testEmptySignature() throws {
        try parse(command: EmptyCmd(), args: [])
        
        do {
            try parse(command: EmptyCmd(), args: ["arg"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires exactly 0 arguments")
        }
    }
    
    func testRequiredParameters() throws {
        do {
            try parse(command: Req2Cmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires exactly 2 arguments")
        }
        
        let req2 = try parse(command: Req2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(req2.req1.value, "arg1")
        XCTAssertEqual(req2.req2.value, "arg2")
        
        do {
            try parse(command: Req2Cmd(), args: ["arg1", "arg2", "arg3"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires exactly 2 arguments")
        }
    }
    
    func testOptionalParameters() throws {
        let cmd1 = try parse(command: Opt2Cmd(), args: [])
        XCTAssertEqual(cmd1.opt1.value, nil)
        XCTAssertEqual(cmd1.opt2.value, nil)
        
        let cmd2 = try parse(command: Opt2Cmd(), args: ["arg1"])
        XCTAssertEqual(cmd2.opt1.value, "arg1")
        XCTAssertEqual(cmd2.opt2.value, nil)
        
        let cmd3 = try parse(command: Opt2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd3.opt1.value, "arg1")
        XCTAssertEqual(cmd3.opt2.value, "arg2")
        
        do {
            try parse(command: Opt2Cmd(), args: ["arg1", "arg2", "arg3"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires between 0 and 2 arguments")
        }
    }
    
    func testOptionalParametersWithInheritance() throws {
        let cmd1 = try parse(command: Opt2InhCmd(), args: [])
        XCTAssertEqual(cmd1.opt1.value, nil)
        XCTAssertEqual(cmd1.opt2.value, nil)
        XCTAssertEqual(cmd1.opt3.value, nil)

        let cmd2 = try parse(command: Opt2InhCmd(), args: ["arg1"])
        XCTAssertEqual(cmd2.opt1.value, "arg1")
        XCTAssertEqual(cmd2.opt2.value, nil)
        XCTAssertEqual(cmd2.opt3.value, nil)
        
        let cmd3 = try parse(command: Opt2InhCmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd3.opt1.value, "arg1")
        XCTAssertEqual(cmd3.opt2.value, "arg2")
        XCTAssertEqual(cmd3.opt3.value, nil)
        
        let cmd4 = try parse(command: Opt2InhCmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd4.opt1.value, "arg1")
        XCTAssertEqual(cmd4.opt2.value, "arg2")
        XCTAssertEqual(cmd4.opt3.value, "arg3")
        
        do {
            try parse(command: Opt2InhCmd(), args: ["arg1", "arg2", "arg3", "arg4"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires between 0 and 3 arguments")
        }
    }
    
    func testCollectedRequiredParameters() throws {
        do {
            try parse(command: ReqCollectedCmd(), args: [])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires at least 1 argument")
        }
        
        do {
            try parse(command: Req2CollectedCmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires at least 2 arguments")
        }

        let cmd1 = try parse(command: Req2CollectedCmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd1.req1.value, "arg1")
        XCTAssertEqual(cmd1.req2.value, ["arg2"])
        
        let cmd2 = try parse(command: Req2CollectedCmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd2.req1.value, "arg1")
        XCTAssertEqual(cmd2.req2.value, ["arg2", "arg3"])
    }
    
    func testCollectedOptionalParameters() throws {
        let cmd1 = try parse(command: Opt2CollectedCmd(), args: [])
        XCTAssertEqual(cmd1.opt1.value, nil)
        XCTAssertEqual(cmd1.opt2.value, [])
        
        let cmd2 = try parse(command: Opt2CollectedCmd(), args: ["arg1"])
        XCTAssertEqual(cmd2.opt1.value, "arg1")
        XCTAssertEqual(cmd2.opt2.value, [])
        
        let cmd3 = try parse(command: Opt2CollectedCmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd3.opt1.value, "arg1")
        XCTAssertEqual(cmd3.opt2.value, ["arg2"])
        
        let cmd4 = try parse(command: Opt2CollectedCmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd4.opt1.value, "arg1")
        XCTAssertEqual(cmd4.opt2.value, ["arg2", "arg3"])
    }
    
    func testCombinedRequiredAndOptionalParameters() throws {
        do {
            try parse(command: Req2Opt2Cmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires between 2 and 4 arguments")
        }
        
        let cmd1 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd1.req1.value, "arg1")
        XCTAssertEqual(cmd1.req2.value, "arg2")
        XCTAssertEqual(cmd1.opt1.value, nil)
        XCTAssertEqual(cmd1.opt2.value, nil)
        
        let cmd2 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd2.req1.value, "arg1")
        XCTAssertEqual(cmd2.req2.value, "arg2")
        XCTAssertEqual(cmd2.opt1.value, "arg3")
        XCTAssertEqual(cmd2.opt2.value, nil)
        
        let cmd3 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3", "arg4"])
        XCTAssertEqual(cmd3.req1.value, "arg1")
        XCTAssertEqual(cmd3.req2.value, "arg2")
        XCTAssertEqual(cmd3.opt1.value, "arg3")
        XCTAssertEqual(cmd3.opt2.value, "arg4")
        
        do {
            try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3", "arg4", "arg5"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires between 2 and 4 arguments")
        }
    }
    
    func testEmptyOptionalCollectedParameter() throws { // Tests regression
        let cmd = try parse(command: OptCollectedCmd(), args: [])
        XCTAssertEqual(cmd.opt1.value, [])
    }
    
    func testFullParse() throws {
        let cmd = TestCommand()
        let cli = CLI.createTester(commands: [cmd])
        
        let args = ArgumentList(arguments: ["tester", "test", "-s", "favTest", "-t", "3", "SwiftCLI"])
        let path = try DefaultParser(commandGroup: cli, arguments: args).parse()
        
        XCTAssertEqual(path.joined(), "tester test")
        XCTAssertTrue(path.command === cmd)
        
        XCTAssertEqual(cmd.testName.value, "favTest")
        XCTAssertEqual(cmd.testerName.value, "SwiftCLI")
        XCTAssertTrue(cmd.silent.value)
        XCTAssertEqual(cmd.times.value, 3)
    }
    
 }
