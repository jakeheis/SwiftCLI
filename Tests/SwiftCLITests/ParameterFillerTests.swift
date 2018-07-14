//
//  ParameterFillerTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 4/18/18.
//

import XCTest
import SwiftCLI

class ParameterFillerTests: XCTestCase {

    static var allTests : [(String, (ParameterFillerTests) -> () throws -> Void)] {
        return [
            ("testEmptySignature", testEmptySignature),
            ("testRequiredParameters", testRequiredParameters),
            ("testOptionalParameters", testOptionalParameters),
            ("testOptionalParametersWithInheritance", testOptionalParametersWithInheritance),
            ("testCollectedRequiredParameters", testCollectedRequiredParameters),
            ("testCollectedOptionalParameters", testCollectedOptionalParameters),
            ("testCombinedRequiredAndOptionalParameters", testCombinedRequiredAndOptionalParameters),
            ("testEmptyOptionalCollectedParameter", testEmptyOptionalCollectedParameter),
        ]
    }
    
    @discardableResult
    func parse<T: Command>(command: T, args: [String]) throws -> T {
        let path = CommandPath(command: command)
        let registry = OptionRegistry(routable: command)
        let arguments = ArgumentList(arguments: args)
        try DefaultParameterFiller().parse(commandPath: path, optionRegistry: registry, arguments: arguments)
        return command
    }
    
    func testEmptySignature() throws {
        try parse(command: EmptyCmd(), args: [])
        
        do {
            try parse(command: EmptyCmd(), args: ["arg"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.minCount, 0)
            XCTAssertEqual(error.maxCount, 0)
        }
    }
    
    func testRequiredParameters() throws {
        do {
            try parse(command: Req2Cmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.minCount, 2)
            XCTAssertEqual(error.maxCount, 2)
        }
        
        let req2 = try parse(command: Req2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(req2.req1.value, "arg1")
        XCTAssertEqual(req2.req2.value, "arg2")
        
        do {
            try parse(command: Req2Cmd(), args: ["arg1", "arg2", "arg3"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.minCount, 2)
            XCTAssertEqual(error.maxCount, 2)
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
            XCTAssertEqual(error.minCount, 0)
            XCTAssertEqual(error.maxCount, 2)
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
            XCTAssertEqual(error.minCount, 0)
            XCTAssertEqual(error.maxCount, 3)
        }
    }
    
    func testCollectedRequiredParameters() throws {
        do {
            try parse(command: ReqCollectedCmd(), args: [])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.minCount, 1)
            XCTAssertNil(error.maxCount)
        }
        
        do {
            try parse(command: Req2CollectedCmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.minCount, 2)
            XCTAssertNil(error.maxCount)
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
            XCTAssertEqual(error.minCount, 2)
            XCTAssertEqual(error.maxCount, 4)
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
            XCTAssertEqual(error.minCount, 2)
            XCTAssertEqual(error.maxCount, 4)
        }
    }
    
    func testEmptyOptionalCollectedParameter() throws { // Tests regression
        let cmd = try parse(command: OptCollectedCmd(), args: [])
        XCTAssertEqual(cmd.opt1.value, [])
    }

}
