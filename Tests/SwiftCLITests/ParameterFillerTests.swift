//
//  ParameterFillerTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 4/18/18.
//

import XCTest
import SwiftCLI

class ParameterFillerTests: XCTestCase {
    
    func testEmptySignature() throws {
        try parse(command: EmptyCmd(), args: [])
        
        assertParseNumberError(command: EmptyCmd(), args: ["arg"], min: 0, max: 0)
    }
    
    func testRequiredParameters() throws {
        assertParseNumberError(command: Req2Cmd(), args: ["arg"], min: 2, max: 2)
        
        let req2 = try parse(command: Req2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(req2.req1.value, "arg1")
        XCTAssertEqual(req2.req2.value, "arg2")
        
        assertParseNumberError(command: Req2Cmd(), args: ["arg1", "arg2", "arg3"], min: 2, max: 2)
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
        
        assertParseNumberError(command: Opt2Cmd(), args: ["arg1", "arg2", "arg3"], min: 0, max: 2)
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
        
        assertParseNumberError(command: Opt2InhCmd(), args: ["arg1", "arg2", "arg3", "arg4"], min: 0, max: 3)
    }
    
    func testCollectedRequiredParameters() throws {
        assertParseNumberError(command: ReqCollectedCmd(), args: [], min: 1, max: nil)
        
        assertParseNumberError(command: Req2CollectedCmd(), args: ["arg1"], min: 2, max: nil)
        
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
        assertParseNumberError(command: Req2Opt2Cmd(), args: ["arg1"], min: 2, max: 4)
        
        let cmd1 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd1.req1.value, "arg1")
        XCTAssertEqual(cmd1.req2.value, "arg2")
        XCTAssertNil(cmd1.opt1.value)
        XCTAssertNil(cmd1.opt2.value)
        
        let cmd2 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd2.req1.value, "arg1")
        XCTAssertEqual(cmd2.req2.value, "arg2")
        XCTAssertEqual(cmd2.opt1.value, "arg3")
        XCTAssertNil(cmd2.opt2.value)
        
        let cmd3 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3", "arg4"])
        XCTAssertEqual(cmd3.req1.value, "arg1")
        XCTAssertEqual(cmd3.req2.value, "arg2")
        XCTAssertEqual(cmd3.opt1.value, "arg3")
        XCTAssertEqual(cmd3.opt2.value, "arg4")
        
        assertParseNumberError(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3", "arg4", "arg5"], min: 2, max: 4)
    }
    
    func testEmptyOptionalCollectedParameter() throws { // Tests regression
        let cmd = try parse(command: OptCollectedCmd(), args: [])
        XCTAssertEqual(cmd.opt1.value, [])
    }
    
    func testCustomParameter() throws {
        assertParseNumberError(command: EnumCmd(), args: [], min: 1, max: 3)
        
        let cmd = EnumCmd()
        XCTAssertThrowsSpecificError(
            expression: try parse(command: cmd, args: ["value"]),
            error: { (error: ParameterError) in
                guard case .invalidValue(let namedParam, .conversionError) = error.kind else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(namedParam.name, "speed")
                XCTAssert(namedParam.param === cmd.speed)
        })
        
        let fast = try parse(command: EnumCmd(), args: ["fast"])
        XCTAssertEqual(fast.speed.value.rawValue, "fast")
        
        let slow = try parse(command: EnumCmd(), args: ["slow"])
        XCTAssertEqual(slow.speed.value.rawValue, "slow")
        
        assertParseNumberError(command: EnumCmd(), args: ["slow", "value", "3", "fourth"], min: 1, max: 3)
    }
    
    func testValidatedParameter() throws {
        let cmd1 = try parse(command: ValidatedParamCmd(), args: [])
        XCTAssertNil(cmd1.age.value)
        
        let cmd2 = ValidatedParamCmd()
        XCTAssertThrowsSpecificError(
            expression: try parse(command: cmd2, args: ["16"]),
            error: { (error: ParameterError) in
                guard case .invalidValue(let namedParam, .validationError(let validation)) = error.kind else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(namedParam.name, "age")
                XCTAssert(namedParam.param === cmd2.age)
                XCTAssertEqual(validation.message, "must be greater than 18")
        })
        
        let cmd3 = try parse(command: ValidatedParamCmd(), args: ["20"])
        XCTAssertEqual(cmd3.age.value, 20)
    }
    
    // MARK: -
    
    @discardableResult
    private func parse<T: Command>(command: T, args: [String]) throws -> T {
        let cli = CLI(name: "tester", commands: [command])
        let arguments = ArgumentList(arguments: [command.name] + args)
        let routed = try Parser().parse(cli: cli, arguments: arguments)
        XCTAssert(routed.command === command)

        return command
    }
    
    private func assertParseNumberError<T: Command>(command: T, args: [String], min: Int, max: Int?, file: StaticString = #file, line: UInt = #line) {
        XCTAssertThrowsSpecificError(
            expression: try parse(command: command, args: args), file: file, line: line,
            error: { (error: ParameterError) in
                guard case let .wrongNumber(aMin, aMax) = error.kind else {
                    XCTFail("Expected error to be .wrongNumber(\(min), \(max as Any)); got .\(error.kind)", file: file, line: line)
                    return
                }
                XCTAssertEqual(aMin, min, file: file, line: line)
                XCTAssertEqual(aMax, max, file: file, line: line)
        })
    }

}
