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
    
    var options = OptionRegistry()
    
    override func setUp() {
        super.setUp()
        
        options = OptionRegistry()
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
        
        let result = parse(arguments: arguments, with: options)

        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        XCTAssert(result == .success, "Option parse should succeed when all flags are added with add(flags:)")
        
        XCTAssert(aBlockCalled && bBlockCalled, "Options should execute the closures of passed flags")
    }
    
    func testSimpleKeyParsing() {
        var aValue: String?
        var bValue: String?
        
        options.add(keys: ["-a"]) {(key, value) in aValue = value }
        options.add(keys: ["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a apple -b banana")
        
        let result = parse(arguments: arguments, with: options)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        XCTAssert(result == .success, "Option parse should succeed when all keys are added with add(keys:)")
        
        XCTAssertEqual(aValue ?? "", "apple", "Options should execute the closures of passed keys")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysParsing() {
        var aBlockCalled = false
        var bValue: String?
        
        options.add(flags: ["-a"]) {(flag) in aBlockCalled = true }
        options.add(keys: ["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a -b banana")
        
        let result = parse(arguments: arguments, with: options)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")

        XCTAssert(result == .success, "Option parse should succeed when all flags/keys are added with add(flags/keys:)")
        
        XCTAssert(aBlockCalled, "Options should execute the closures of passed flags")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysAndArgumentsParsing() {
        var aBlockCalled = false
        var bValue: String?
        
        options.add(flags: ["-a"]) {(flag) in aBlockCalled = true }
        options.add(keys: ["-b"]) {(key, value) in bValue = value }
        
        let arguments = RawArguments(argumentString: "tester -a argument -b banana")
        
        let result = parse(arguments: arguments, with: options)
        
        XCTAssertEqual(arguments.unclassifiedArguments.map { $0.value }, ["argument"], "Options should classify all option arguments as options")
        
        XCTAssert(result == .success, "Option parse should succeed when all flags/keys are added with add(flags/keys:)")
        
        XCTAssert(aBlockCalled, "Options should execute the closures of passed flags")
        XCTAssertEqual(bValue ?? "", "banana", "Options should execute the closures of passed keys")
    }
    
    func testUnrecognizedOptions() {
        options.add(flags: ["-a"]) {_ in}
        
        let arguments = RawArguments(argumentString: "tester -a -b")
        
        let result = parse(arguments: arguments, with: options)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        if case let .incorrectOptionUsage(incorrectOptionUsage) = result {
            XCTAssertEqual(incorrectOptionUsage.unrecognizedOptions.first ?? "", "-b", "Options should identify when unrecognized options are used")
        } else {
            XCTFail("Options should identify when unrecognized options are used")
        }
    }
    
    func testKeysNotGivenValues() {
        options.add(keys: ["-a"])  {_,_ in}
        options.add(flags: ["-b"]) {_ in}
        
        let arguments = RawArguments(argumentString: "tester -a -b")
        
        let result = parse(arguments: arguments, with: options)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        if case let .incorrectOptionUsage(incorrectOptionUsage) = result {
            XCTAssertEqual(incorrectOptionUsage.keysNotGivenValue.first ?? "", "-a", "Options should identify when keys are not given values")
        } else {
            XCTFail("Options should identify when keys are not given values")
        }
    }

    func testFlagSplitting() {
        var aBlockCalled = false
        var bBlockCalled = false
        
        options.add(flags: ["-a"]) {flag in aBlockCalled = true }
        options.add(flags: ["-b"]) {flag in bBlockCalled = true }
        
        let arguments = RawArguments(argumentString: "tester -ab")
        
        let result = parse(arguments: arguments, with: options)
        
        XCTAssert(arguments.unclassifiedArguments.isEmpty, "Options should classify all option arguments as options")
        
        XCTAssert(result == .success, "Options should recognize all flags added with onFlags")
        
        XCTAssert(aBlockCalled && bBlockCalled, "Options should execute the closures of passed flags")
    }
    
    func testExitEarlyFlags() {
        options.add(flags: ["-a"]) {_ in}
        options.add(flags: ["-b"]) {_ in}
        options.exitEarlyOptions = ["-a"]
        
        var arguments = RawArguments(argumentString: "tester -a")
        let result1 = parse(arguments: arguments, with: options)
        XCTAssert(result1 == .exitEarly, "Options should exitEarly when exit early flag is given")
        
        arguments = RawArguments(argumentString: "tester -b")
        let result2 = parse(arguments: arguments, with: options)
        XCTAssert(result2 == .success, "Options should not exitEarly when no exit early flag is given")
    }
    
    // MARK: - Helpers
    
    private func parse(arguments: RawArguments, with optionRegistry: OptionRegistry) -> OptionParserResult {
        return DefaultOptionParser().recognizeOptions(in: arguments, from: optionRegistry)
    }
    
}
