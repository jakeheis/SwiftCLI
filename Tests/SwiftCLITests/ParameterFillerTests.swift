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
        
        do {
            try parse(command: EmptyCmd(), args: ["arg"])
            XCTFail()
        } catch let error as ParameterError {
            assertMinCount(of: error, is: 0)
            assertMaxCount(of: error, is: 0)
        }
    }
    
    func testRequiredParameters() throws {
        do {
            try parse(command: Req2Cmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            assertMinCount(of: error, is: 2)
            assertMaxCount(of: error, is: 2)
        }
        
        let req2 = try parse(command: Req2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(req2.req1.value, "arg1")
        XCTAssertEqual(req2.req2.value, "arg2")
        
        do {
            try parse(command: Req2Cmd(), args: ["arg1", "arg2", "arg3"])
            XCTFail()
        } catch let error as ParameterError {
            assertMinCount(of: error, is: 2)
            assertMaxCount(of: error, is: 2)
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
            assertMinCount(of: error, is: 0)
            assertMaxCount(of: error, is: 2)
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
            assertMinCount(of: error, is: 0)
            assertMaxCount(of: error, is: 3)
        }
    }
    
    func testCollectedRequiredParameters() throws {
        do {
            try parse(command: ReqCollectedCmd(), args: [])
            XCTFail()
        } catch let error as ParameterError {
            assertMinCount(of: error, is: 1)
            assertMaxCount(of: error, is: nil)
        }
        
        do {
            try parse(command: Req2CollectedCmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            assertMinCount(of: error, is: 2)
            assertMaxCount(of: error, is: nil)
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
            assertMinCount(of: error, is: 2)
            assertMaxCount(of: error, is: 4)
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
            assertMinCount(of: error, is: 2)
            assertMaxCount(of: error, is: 4)
        }
    }
    
    public func XCTAssertThrowsSpecificError<T, E: Error>(
        expression: @autoclosure () throws -> T,
        file: StaticString = #file,
        line: UInt = #line,
        error errorHandler: (E) -> Void) {
        XCTAssertThrowsError(expression, file: file, line: line) { (error) in
            guard let specificError = error as? E else {
                XCTFail("Error must be type \(String(describing: E.self)), is \(String(describing: type(of: error)))", file: file, line: line)
                return
            }
            errorHandler(specificError)
        }
    }
    
    func testEmptyOptionalCollectedParameter() throws { // Tests regression
        let cmd = try parse(command: OptCollectedCmd(), args: [])
        XCTAssertEqual(cmd.opt1.value, [])
    }
    
    func testCustomParameter() throws {
        XCTAssertThrowsSpecificError(
            expression: try parse(command: EnumCmd(), args: []),
            error: { (error: ParameterError) in
                assertMinCount(of: error, is: 1)
                assertMaxCount(of: error, is: 1)
        })
        
        XCTAssertThrowsSpecificError(
            expression: try parse(command: EnumCmd(), args: ["value"]),
            error: { (error: ParameterError) in
                guard case let .illegalTypeForParameter(param, type) = error.kind else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(param, "speed")
                XCTAssert(type is EnumCmd.Speed.Type)
        })
        
        let fast = try parse(command: EnumCmd(), args: ["fast"])
        XCTAssertEqual(fast.speed.value.rawValue, "fast")
        
        let slow = try parse(command: EnumCmd(), args: ["slow"])
        XCTAssertEqual(slow.speed.value.rawValue, "slow")
        
        XCTAssertThrowsSpecificError(
            expression: try parse(command: EnumCmd(), args: ["slow", "second"]),
            error: { (error: ParameterError) in
                assertMinCount(of: error, is: 1)
                assertMaxCount(of: error, is: 1)
        })
    }
    
    // MARK: -
    
    @discardableResult
    private func parse<T: Command>(command: T, args: [String]) throws -> T {
        let path = CommandPath(command: command)
        let registry = OptionRegistry(routable: command)
        let arguments = ArgumentList(arguments: args)
        try DefaultParameterFiller().parse(commandPath: path, optionRegistry: registry, arguments: arguments)
        return command
    }
    
    private func assertMinCount(of error: ParameterError, is num: Int, file: StaticString = #file, line: UInt = #line) {
        guard case let .wrongNumber(iterator) = error.kind else {
            XCTFail(file: file, line: line)
            return
        }
        XCTAssertEqual(iterator.minCount, num, file: file, line: line)
    }
    
    private func assertMaxCount(of error: ParameterError, is num: Int?, file: StaticString = #file, line: UInt = #line) {
        guard case let .wrongNumber(iterator) = error.kind else {
            XCTFail(file: file, line: line)
            return
        }
        XCTAssertEqual(iterator.maxCount, num, file: file, line: line)
    }
    

}
