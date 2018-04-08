//
//  OptionParserTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 8/10/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI


extension ParserTests {
    
//   static var allTests : [(String, (OptionParserTests) -> () throws -> Void)] {
//        return [
//            ("testSimpleFlagParsing", testSimpleFlagParsing),
//            ("testSimpleKeyParsing", testSimpleKeyParsing),
//            ("testKeyValueParsing", testKeyValueParsing),
//            ("testCombinedFlagsAndKeysParsing", testCombinedFlagsAndKeysParsing),
//            ("testCombinedFlagsAndKeysAndArgumentsParsing", testCombinedFlagsAndKeysAndArgumentsParsing),
//            ("testUnrecognizedOptions", testUnrecognizedOptions),
//            ("testKeysNotGivenValues", testKeysNotGivenValues),
//            ("testIllegalOptionFormat", testIllegalOptionFormat),
//            ("testFlagSplitting", testFlagSplitting),
//            ("testGroupRestriction", testGroupRestriction)
//        ]
//    }
    
    // MARK: - Tests
    
    func testSimpleFlagParsing() throws {
        let cmd = DoubleFlagCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -a -b")
        let cli = CLI.createTester(commands: [cmd])

        _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        XCTAssert(cmd.alpha.value && cmd.beta.value, "Options should update the values of passed flags")
    }
    
    func testSimpleKeyParsing() throws {
        let cmd = DoubleKeyCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -a apple -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        
        XCTAssertEqual(cmd.alpha.value, "apple", "Options should update the values of passed keys")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should update the values of passed keys")
    }
    
    func testKeyValueParsing() throws {
        let cmd = IntKeyCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -a 7")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        
        XCTAssert(cmd.alpha.value == 7, "Options should parse int")
    }
    
    func testCombinedFlagsAndKeysParsing() throws {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -a -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        
        XCTAssert(cmd.alpha.value, "Options should execute the closures of passed flags")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysAndArgumentsParsing() throws {
        let cmd = FlagKeyParamCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -a argument -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        
        XCTAssert(cmd.alpha.value, "Options should execute the closures of passed flags")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
        XCTAssertEqual(cmd.param.value, "argument")
    }
    
    func testUnrecognizedOptions() throws {
        let cmd = FlagCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -a -b")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Unrecognized option: -b")
        }
    }
    
    func testKeysNotGivenValues() throws {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -b -a")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Expected a value to follow: -b")
        }
    }
    
    func testIllegalOptionFormat() throws {
        let cmd = IntKeyCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -a val")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Illegal type passed to -a: 'val'")
        }
    }

    func testFlagSplitting() throws {
        let cmd = DoubleFlagCmd()
        let arguments = ArgumentList(argumentString: "tester cmd -ab")
        OptionSplitter().manipulate(arguments: arguments)
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        
        XCTAssert(cmd.alpha.value && cmd.beta.value, "Options should execute the closures of passed flags")
    }
    
    func testGroupRestriction() throws {
        let cmd1 = ExactlyOneCmd()
        let arguments1 = ArgumentList(argumentString: "tester cmd -a -b")
        
        do {
            _ = try DefaultParser(commandGroup: CLI.createTester(commands: [cmd1]), arguments: arguments1).parse()
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Must pass exactly one of the following: --alpha --beta")
        }
        
        let cmd2 = ExactlyOneCmd()
        let arguments2 = ArgumentList(argumentString: "tester cmd -a")
        _ = try DefaultParser(commandGroup: CLI.createTester(commands: [cmd2]), arguments: arguments2).parse()
        XCTAssertTrue(cmd2.alpha.value)
        XCTAssertFalse(cmd2.beta.value)
        
        let cmd3 = ExactlyOneCmd()
        let arguments3 = ArgumentList(argumentString: "tester cmd -b")
        _ = try DefaultParser(commandGroup: CLI.createTester(commands: [cmd3]), arguments: arguments3).parse()
        XCTAssertTrue(cmd3.beta.value)
        XCTAssertFalse(cmd3.alpha.value)
        
        let cmd4 = ExactlyOneCmd()
        let arguments4 = ArgumentList(argumentString: "tester cmd")
        do {
            _ = try DefaultParser(commandGroup: CLI.createTester(commands: [cmd4]), arguments: arguments4).parse()
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Must pass exactly one of the following: --alpha --beta")
        }
    }
    
}


