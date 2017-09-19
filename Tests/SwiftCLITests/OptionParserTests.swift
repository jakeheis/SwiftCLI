//
//  OptionParserTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/10/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class OptionParserTests: XCTestCase {
    
   static var allTests : [(String, (OptionParserTests) -> () throws -> Void)] {
        return [
            ("testSimpleFlagParsing", testSimpleFlagParsing),
            ("testSimpleKeyParsing", testSimpleKeyParsing),
            ("testKeyValueParsing", testKeyValueParsing),
            ("testCombinedFlagsAndKeysParsing", testCombinedFlagsAndKeysParsing),
            ("testCombinedFlagsAndKeysAndArgumentsParsing", testCombinedFlagsAndKeysAndArgumentsParsing),
            ("testUnrecognizedOptions", testUnrecognizedOptions),
            ("testKeysNotGivenValues", testKeysNotGivenValues),
            ("testIllegalOptionFormat", testIllegalOptionFormat),
            ("testFlagSplitting", testFlagSplitting),
            ("testGroupRestriction", testGroupRestriction)
        ]
    }
    
    override func setUp() {
        super.setUp()
    }
    
    // MARK: - Tests
    
    func testSimpleFlagParsing() {
        let cmd = DoubleFlagCmd()
        let arguments = ArgumentList(argumentString: "tester -a -b")
        assertParseSuccess(arguments: arguments, with: cmd)

        XCTAssert(arguments.head == nil, "Options should classify all option arguments as options")
        
        XCTAssert(cmd.alpha.value && cmd.beta.value, "Options should execute the closures of passed flags")
    }
    
    func testSimpleKeyParsing() {
        let cmd = DoubleKeyCmd()
        let arguments = ArgumentList(argumentString: "tester -a apple -b banana")
        assertParseSuccess(arguments: arguments, with: cmd)
        
        XCTAssert(arguments.head == nil, "Options should classify all option arguments as options")
        
        XCTAssertEqual(cmd.alpha.value, "apple", "Options should execute the closures of passed keys")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
    }
    
    func testKeyValueParsing() {
        let cmd = IntKeyCmd()
        let arguments = ArgumentList(argumentString: "tester -a 7")
        assertParseSuccess(arguments: arguments, with: cmd)
        
        XCTAssert(cmd.alpha.value == 7, "Options should parse int")
    }
    
    func testCombinedFlagsAndKeysParsing() {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(argumentString: "tester -a -b banana")
        
        assertParseSuccess(arguments: arguments, with: cmd)
        
        XCTAssert(arguments.head == nil, "Options should classify all option arguments as options")
        
        XCTAssert(cmd.alpha.value, "Options should execute the closures of passed flags")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysAndArgumentsParsing() {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(argumentString: "tester -a argument -b banana")
        
        assertParseSuccess(arguments: arguments, with: cmd)
        
        XCTAssert(arguments.head?.value ==  "argument" && arguments.head?.next == nil, "Options should classify all option arguments as options")
        
        XCTAssert(cmd.alpha.value, "Options should execute the closures of passed flags")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
    }
    
    func testUnrecognizedOptions() {
        let cmd = FlagCmd()
        let arguments = ArgumentList(argumentString: "tester -a -b")
        
        assertParseFailure(arguments: arguments, with: cmd, error: .unrecognizedOption("-b"))
    }
    
    func testKeysNotGivenValues() {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(argumentString: "tester -b -a")
        
        assertParseFailure(arguments: arguments, with: cmd, error: .noValueForKey("-b"))
    }
    
    func testIllegalOptionFormat() {
        let cmd = IntKeyCmd()
        let arguments = ArgumentList(argumentString: "tester -a val")
        
        assertParseFailure(arguments: arguments, with: cmd, error: .illegalKeyValue("-a", "val"))
    }

    func testFlagSplitting() {
        let cmd = DoubleFlagCmd()
        let arguments = ArgumentList(argumentString: "tester -ab")
        OptionSplitter().manipulate(arguments: arguments)
        
        assertParseSuccess(arguments: arguments, with: cmd)
        
        XCTAssert(arguments.head == nil, "Options should classify all option arguments as options")
        
        XCTAssert(cmd.alpha.value && cmd.beta.value, "Options should execute the closures of passed flags")
    }
    
    func testGroupRestriction() {
        let cmd1 = ExactlyOneCmd()
        let arguments1 = ArgumentList(argumentString: "tester -a -b")
        assertParseFailure(arguments: arguments1, with: cmd1, error: .groupRestrictionFailed(cmd1.optionGroups[0]))
        
        let cmd2 = ExactlyOneCmd()
        let arguments2 = ArgumentList(argumentString: "tester -a")
        assertParseSuccess(arguments: arguments2, with: cmd2)
        
        let cmd3 = ExactlyOneCmd()
        let arguments3 = ArgumentList(argumentString: "tester -b")
        assertParseSuccess(arguments: arguments3, with: cmd3)
        
        let cmd4 = ExactlyOneCmd()
        let arguments4 = ArgumentList(argumentString: "tester")
        assertParseFailure(arguments: arguments4, with: cmd4, error: .groupRestrictionFailed(cmd4.optionGroups[0]))
    }
    
    // MARK: - Helpers
    
    private func assertParseSuccess(arguments: ArgumentList, with cmd: Command) {
        do {
            let cli = CLI(name: "tester")
            let registry = OptionRegistry(options: cmd.options(for: cli), optionGroups: cmd.optionGroups)
            try DefaultOptionRecognizer().recognizeOptions(from: registry, in: arguments)
        } catch {
            XCTFail()
        }
    }
    
    private func assertParseFailure(arguments: ArgumentList, with cmd: Command, error expectedError: OptionRecognizerError) {
        do {
            let cli = CLI(name: "tester")
            let registry = OptionRegistry(options: cmd.options(for: cli), optionGroups: cmd.optionGroups)
            try DefaultOptionRecognizer().recognizeOptions(from: registry, in: arguments)
            XCTFail()
        } catch let error as OptionRecognizerError {
            switch (error, expectedError) {
            case (.unrecognizedOption(let option1), .unrecognizedOption(let option2)) where option1 == option2:
                break
            case (.illegalKeyValue(let k1, let v1), .illegalKeyValue(let k2, let v2)) where k1 == k2 && v1 == v2:
                break
            case (.noValueForKey(let k1), .noValueForKey(let k2)) where k1 == k2:
                break
            case (.groupRestrictionFailed(let g1), .groupRestrictionFailed(let g2))
                where g1.options.reduce("", { $0 + $1.names.joined() }) == g2.options.reduce("", { $0 + $1.names.joined() }):
                break
            default:
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
}
