//
//  OptionsSpec.swift
//  Example
//
//  Created by Jake Heiser on 8/10/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Cocoa
import XCTest

class OptionsTests: XCTestCase {
    
    var options = Options()
    
    override func setUp() {
        super.setUp()
        
        options = Options()
    }
    
    // MARK: - Tests
    
    func testOnFlags() {
        options.onFlags(["-a", "--awesome"], block: nil)
        XCTAssert(contains(options.flagOptions.keys, "-a"), "Options should expect flags after a call to onFlags")
        XCTAssert(contains(options.flagOptions.keys, "--awesome"), "Options should expect flags after a call to onFlags")
    }
    
    func testOnKeys() {
        options.onKeys(["-a", "--awesome"], block: nil)
        XCTAssert(contains(options.keyOptions.keys, "-a"), "Options should expect keys after a call to onKeys")
        XCTAssert(contains(options.keyOptions.keys, "--awesome"), "Options should expect keys after a call to onKeys")
    }
    
    func testSimpleFlagParsing() {
        var aBlockCalled = false
        var bBlockCalled = false
        
        options.onFlags(["-a"]) {(flag) in aBlockCalled = true }
        options.onFlags(["-b"]) {(flag) in bBlockCalled = true }
        
        let arguments = RawArguments(argumentString: "tester -a -b")
        
        options.recognizeOptionsInArguments(arguments)

        XCTAssert(arguments.unclassifiedArguments().count == 0, "Options should classify all option arguments as options")
        
        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled && bBlockCalled, "Options should execute the closures of passed flags")
    }
    
    func testSimpleKeyParsing() {
        var aValue: String?
        var bValue: String?
        
        options.onKeys(["-a"]) {(key, value) in aValue = value }
        options.onKeys(["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a apple -b banana")
        
        options.recognizeOptionsInArguments(arguments)
        
        XCTAssert(arguments.unclassifiedArguments().count == 0, "Options should classify all option arguments as options")
        
        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssertEqual(aValue ?? "", "apple", "Options should execute the closures of passed keys")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysParsing() {
        var aBlockCalled = false
        var bValue: String?
        
        options.onFlags(["-a"]) {(flag) in aBlockCalled = true }
        options.onKeys(["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a -b banana")
        
        options.recognizeOptionsInArguments(arguments)
        
        XCTAssert(arguments.unclassifiedArguments().count == 0, "Options should classify all option arguments as options")

        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled, "Options should execute the closures of passed flags")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysAndArgumentsParsing() {
        var aBlockCalled = false
        var bValue: String?
        
        options.onFlags(["-a"]) {(flag) in aBlockCalled = true }
        options.onKeys(["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a argument -b banana")
        
        options.recognizeOptionsInArguments(arguments)
        
        XCTAssertEqual(arguments.unclassifiedArguments(), ["argument"], "Options should classify all option arguments as options")
        
        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled, "Options should execute the closures of passed flags")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testUnrecognizedOptions() {
        options.onFlags(["-a"], block: nil)
        
        let arguments = RawArguments(argumentString: "tester -a -b")
        
        options.recognizeOptionsInArguments(arguments)
        
        XCTAssert(arguments.unclassifiedArguments().count == 0, "Options should classify all option arguments as options")
        
        XCTAssert(options.misusedOptionsPresent(), "Options should identify when unrecognized options are used")
        XCTAssertEqual(options.unrecognizedOptions.first ?? "", "-b", "Options should identify when unrecognized options are used")
    }
    
    func testKeysNotGivenValues() {
        options.onKeys(["-a"], block: nil)
        options.onFlags(["-b"], block: nil)
        
        let arguments = RawArguments(argumentString: "tester -a -b")
        
        options.recognizeOptionsInArguments(arguments)
        
        XCTAssert(arguments.unclassifiedArguments().count == 0, "Options should classify all option arguments as options")
        
        XCTAssert(options.misusedOptionsPresent(), "Options should identify when unrecognized options are used")
        XCTAssertEqual(options.keysNotGivenValue.first ?? "", "-a", "Options should identify when keys are not given values")
    }

    func testFlagSplitting() {
        var aBlockCalled = false
        var bBlockCalled = false
        
        options.onFlags(["-a"]) {flag in aBlockCalled = true }
        options.onFlags(["-b"]) {flag in bBlockCalled = true }
        
        let arguments = RawArguments(argumentString: "tester -ab")
        
        options.recognizeOptionsInArguments(arguments)
        
        XCTAssert(arguments.unclassifiedArguments().count == 0, "Options should classify all option arguments as options")
        
        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled && bBlockCalled, "Options should execute the closures of passed flags")
    }
    
}
