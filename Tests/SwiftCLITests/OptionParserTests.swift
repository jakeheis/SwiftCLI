//
//  OptionsSpec.swift
//  Example
//
//  Created by Jake Heiser on 8/10/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCLI

class OptionsTests: XCTestCase {
    
   static var allTests : [(String, (OptionsTests) -> () throws -> Void)] {
        return [
            ("testFlagDetection", testFlagDetection),
            ("testKeyDetection", testKeyDetection),
            ("testSimpleFlagParsing", testSimpleFlagParsing),
            ("testSimpleKeyParsing", testSimpleKeyParsing),
            ("testCombinedFlagsAndKeysParsing", testCombinedFlagsAndKeysParsing),
            ("testCombinedFlagsAndKeysAndArgumentsParsing", testCombinedFlagsAndKeysAndArgumentsParsing),
            ("testUnrecognizedOptions", testUnrecognizedOptions),
            ("testKeysNotGivenValues", testKeysNotGivenValues),
            ("testFlagSplitting", testFlagSplitting)
        ]
    }
    
    override func setUp() {
        super.setUp()
    }
    
    // MARK: - Tests
    
    func testFlagDetection() {
        let options = OptionRegistry(command: FlagCmd())
        XCTAssert(options.flag(for: "-a") != nil, "Options should expect flags after a call to onFlags")
        XCTAssert(options.flag(for: "--alpha") != nil, "Options should expect flags after a call to onFlags")
        XCTAssert(options.key(for: "-a") == nil, "Options should parse no keys from only flags")
    }
    
    func testKeyDetection() {
        let options = OptionRegistry(command: KeyCmd())
        XCTAssert(options.key(for: "-a") != nil, "Options should expect keys after a call to onKeys")
        XCTAssert(options.key(for: "--alpha") != nil, "Options should expect keys after a call to onKeys")
        XCTAssert(options.flag(for: "-a") == nil, "Options should parse no flags from only keys")
    }
    
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
            try DefaultOptionParser().recognizeOptions(in: arguments, for: cmd)
        } catch {
            XCTFail()
        }
    }
    
    private func assertParseFailure(arguments: ArgumentList, with cmd: Command, error expectedError: OptionParserError) {
        do {
            print(cmd.optionGroups)
            try DefaultOptionParser().recognizeOptions(in: arguments, for: cmd)
            XCTFail()
        } catch let error as OptionParserError {
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

class OptionCmd: Command {
    let name = "cmd"
    let shortDescription = ""
    var helpFlag: Flag? = nil
    func execute() throws {}
}

class FlagCmd: OptionCmd {
    let flag = Flag("-a", "--alpha")
}

class KeyCmd: OptionCmd {
    let key = Key<String>("-a", "--alpha")
}

class DoubleFlagCmd: OptionCmd {
    let alpha = Flag("-a", "--alpha")
    let beta = Flag("-b", "--beta")
}

class DoubleKeyCmd: OptionCmd {
    let alpha = Key<String>("-a", "--alpha")
    let beta = Key<String>("-b", "--beta")
}

class FlagKeyCmd: OptionCmd {
    let alpha = Flag("-a", "--alpha")
    let beta = Key<String>("-b", "--beta")
}

class IntKeyCmd: OptionCmd {
    let alpha = Key<Int>("-a", "--alpha")
}

class ExactlyOneCmd: Command {
    let name = "cmd"
    let shortDescription = ""
    var helpFlag: Flag? = nil
    func execute() throws {}
    
    let alpha = Flag("-a", "--alpha")
    let beta = Flag("-b", "--beta")
    
    let optionGroups: [OptionGroup]
    
    init() {
        optionGroups = [OptionGroup(options: [alpha, beta], restriction: .exactlyOne)]
    }
    
}
