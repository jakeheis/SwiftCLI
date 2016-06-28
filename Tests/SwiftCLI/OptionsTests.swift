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
    
    var options = Options()
    
    override func setUp() {
        super.setUp()
        
        options = Options()
    }
    
    // MARK: - Tests
    
    func testOnFlags() {
        options.add(flags: ["-a", "--awesome"]) {_ in}
        XCTAssert(options.flagBlocks.keys.contains("-a"), "Options should expect flags after a call to onFlags")
        XCTAssert(options.flagBlocks.keys.contains("--awesome"), "Options should expect flags after a call to onFlags")
    }
    
    func testOnKeys() {
        options.add(keys: ["-a", "--awesome"]) {_,_ in}
        XCTAssert(options.keyBlocks.keys.contains("-a"), "Options should expect keys after a call to onKeys")
        XCTAssert(options.keyBlocks.keys.contains("--awesome"), "Options should expect keys after a call to onKeys")
    }
    
    func testSimpleFlagParsing() {
        var aBlockCalled = false
        var bBlockCalled = false
        
        options.add(flags: ["-a"]) {(flag) in aBlockCalled = true }
        options.add(flags: ["-b"]) {(flag) in bBlockCalled = true }
        
        let arguments = RawArguments(argumentString: "tester -a -b")
        
        options.recognizeOptions(in: arguments)

        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled && bBlockCalled, "Options should execute the closures of passed flags")
    }
    
    func testSimpleKeyParsing() {
        var aValue: String?
        var bValue: String?
        
        options.add(keys: ["-a"]) {(key, value) in aValue = value }
        options.add(keys: ["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a apple -b banana")
        
        options.recognizeOptions(in: arguments)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssertEqual(aValue ?? "", "apple", "Options should execute the closures of passed keys")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysParsing() {
        var aBlockCalled = false
        var bValue: String?
        
        options.add(flags: ["-a"]) {(flag) in aBlockCalled = true }
        options.add(keys: ["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a -b banana")
        
        options.recognizeOptions(in: arguments)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")

        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled, "Options should execute the closures of passed flags")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysAndArgumentsParsing() {
        var aBlockCalled = false
        var bValue: String?
        
        options.add(flags: ["-a"]) {(flag) in aBlockCalled = true }
        options.add(keys: ["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a argument -b banana")
        
        options.recognizeOptions(in: arguments)
        
        XCTAssertEqual(arguments.unclassifiedArguments.map { $0.value }, ["argument"], "Options should classify all option arguments as options")
        
        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled, "Options should execute the closures of passed flags")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testUnrecognizedOptions() {
        options.add(flags: ["-a"]) {_ in}
        
        let arguments = RawArguments(argumentString: "tester -a -b")
        
        options.recognizeOptions(in: arguments)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        XCTAssert(options.misusedOptionsPresent(), "Options should identify when unrecognized options are used")
        XCTAssertEqual(options.unrecognizedOptions.first ?? "", "-b", "Options should identify when unrecognized options are used")
    }
    
    func testKeysNotGivenValues() {
        options.add(keys: ["-a"])  {_,_ in}
        options.add(flags: ["-b"]) {_ in}
        
        let arguments = RawArguments(argumentString: "tester -a -b")
        
        options.recognizeOptions(in: arguments)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        XCTAssert(options.misusedOptionsPresent(), "Options should identify when unrecognized options are used")
        XCTAssertEqual(options.keysNotGivenValue.first ?? "", "-a", "Options should identify when keys are not given values")
    }

    func testFlagSplitting() {
        var aBlockCalled = false
        var bBlockCalled = false
        
        options.add(flags: ["-a"]) {flag in aBlockCalled = true }
        options.add(flags: ["-b"]) {flag in bBlockCalled = true }
        
        let arguments = RawArguments(argumentString: "tester -ab")
        
        options.recognizeOptions(in: arguments)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        XCTAssertFalse(options.misusedOptionsPresent(), "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled && bBlockCalled, "Options should execute the closures of passed flags")
    }
    
    func testExitEarlyFlags() {
        options.add(flags: ["-a"]) {_ in}
        options.add(flags: ["-b"]) {_ in}
        options.exitEarlyOptions = ["-a"]
        
        var arguments = RawArguments(argumentString: "tester -a")
        options.recognizeOptions(in: arguments)
        XCTAssert(options.exitEarly, "Options should set exitEarly on when exit early flag is given")
        
        options.exitEarly = false
        
        arguments = RawArguments(argumentString: "tester -b")
        options.recognizeOptions(in: arguments)
        XCTAssertFalse(options.exitEarly, "Options should set exitEarly on when exit early flag is given")
    }
    
}
