//
//  ParserTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 1/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class ParserTests: XCTestCase {
    
    static var allTests : [(String, (ParserTests) -> () throws -> Void)] {
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
            ("testGroupRestriction", testGroupRestriction),
            ("testVaridadicParse", testVaridadicParse),
            ("testBeforeCommand", testBeforeCommand),
            ("testDefaultFlagValue", testDefaultFlagValue),
            ("testFullParse", testFullParse),
            ("testCollectedOptions", testCollectedOptions)
        ]
    }
    
    // MARK: - Option parsing tests
    
    func testSimpleFlagParsing() throws {
        let cmd = DoubleFlagCmd()
        let arguments = ArgumentList(testString: "tester cmd -a -b")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        XCTAssertTrue(cmd.alpha.value)
        XCTAssertTrue(cmd.beta.value)
    }
    
    func testSimpleKeyParsing() throws {
        let cmd = DoubleKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -a apple -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssertEqual(cmd.alpha.value, "apple", "Options should update the values of passed keys")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should update the values of passed keys")
    }
    
    func testKeyValueParsing() throws {
        let cmd = IntKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -a 7")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssertEqual(cmd.alpha.value, 7, "Options should parse int")
    }
    
    func testCombinedFlagsAndKeysParsing() throws {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -a -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssertTrue(cmd.alpha.value, "Options should execute the closures of passed flags")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysAndArgumentsParsing() throws {
        let cmd = FlagKeyParamCmd()
        let arguments = ArgumentList(testString: "tester cmd -a argument -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssert(cmd.alpha.value, "Options should execute the closures of passed flags")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
        XCTAssertEqual(cmd.param.value, "argument")
    }
    
    func testUnrecognizedOptions() throws {
        let cmd = FlagCmd()
        let arguments = ArgumentList(testString: "tester cmd -a -b")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as OptionError {
            guard case let .unrecognizedOption(key) = error.kind, key == "-b" else {
                XCTFail()
                return
            }
        }
    }
    
    func testKeysNotGivenValues() throws {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -b -a")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as OptionError {
            guard case let .expectedValueAfterKey(key) = error.kind, key == "-b" else {
                XCTFail()
                return
            }
        }
    }
    
    func testIllegalOptionFormat() throws {
        let cmd = IntKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -a val")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as OptionError {
            guard case let .illegalTypeForKey(key, type) = error.kind, key == "-a", type == Int.self else {
                XCTFail()
                return
            }
        }
    }
    
    func testFlagSplitting() throws {
        let cmd = DoubleFlagCmd()
        let arguments = ArgumentList(testString: "tester cmd -ab")
        OptionSplitter().manipulate(arguments: arguments)
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssertTrue(cmd.alpha.value)
        XCTAssertTrue(cmd.beta.value)
    }
    
    func testGroupRestriction() throws {
        let cmd1 = ExactlyOneCmd()
        let arguments1 = ArgumentList(testString: "tester cmd -a -b")
        
        do {
            _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd1]), arguments: arguments1)
            XCTFail()
        } catch let error as OptionError {
            guard case let .optionGroupMisuse(group) = error.kind else {
                XCTFail()
                return
            }
            XCTAssert(group === cmd1.optionGroups[0])
        }
        
        let cmd2 = ExactlyOneCmd()
        let arguments2 = ArgumentList(testString: "tester cmd -a")
        _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd2]), arguments: arguments2)
        XCTAssertTrue(cmd2.alpha.value)
        XCTAssertFalse(cmd2.beta.value)
        
        let cmd3 = ExactlyOneCmd()
        let arguments3 = ArgumentList(testString: "tester cmd -b")
        _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd3]), arguments: arguments3)
        XCTAssertTrue(cmd3.beta.value)
        XCTAssertFalse(cmd3.alpha.value)
        
        let cmd4 = ExactlyOneCmd()
        let arguments4 = ArgumentList(testString: "tester cmd")
        do {
            _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd4]), arguments: arguments4)
            XCTFail()
        } catch let error as OptionError {
            guard case let .optionGroupMisuse(group) = error.kind else {
                XCTFail()
                return
            }
            XCTAssert(group === cmd4.optionGroups[0])
        }
    }
    
    func testVaridadicParse() throws {
        let cmd = VariadicKeyCmd()
        let cli = CLI.createTester(commands: [cmd])
        let arguments = ArgumentList(testString: "tester cmd -f firstFile --file secondFile")
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        XCTAssertEqual(cmd.files.values, ["firstFile", "secondFile"])
    }
    
    func testBeforeCommand() throws {
        let cmd = EmptyCmd()
        let yes = Flag("-y")
        
        let cli = CLI.createTester(commands: [cmd])
        cli.globalOptions = [yes]
        let arguments = ArgumentList(testString: "tester -y cmd")
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        XCTAssertTrue(yes.value)
    }
    
    func testDefaultFlagValue() throws {
        let cmd = ReverseFlagCmd()
        
        XCTAssertTrue(cmd.flag.value)
        
        let cli = CLI.createTester(commands: [cmd])
        let arguments = ArgumentList(testString: "tester cmd -r")
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssertFalse(cmd.flag.value)
    }
    
    func testValidation() throws {
        let cmd1 = ValidatedKeyCmd()
        let arguments1 = ArgumentList(testString: "tester cmd -n jake")
        
        do {
            _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd1]), arguments: arguments1)
            XCTFail()
        } catch let error as OptionError {
            guard case let .validationError(option, message) = error.kind else {
                XCTFail()
                return
            }
            XCTAssertEqual(option, "-n")
            XCTAssertEqual(message, "Must be a capitalized first name")
        }
        
        let cmd2 = ValidatedKeyCmd()
        let arguments2 = ArgumentList(testString: "tester cmd -n Jake")
        _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd2]), arguments: arguments2)
        XCTAssertEqual(cmd2.firstName.value, "Jake")
        
        let cmd3 = ValidatedKeyCmd()
        let arguments3 = ArgumentList(testString: "tester cmd -a 15")
        
        do {
            _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd3]), arguments: arguments3)
            XCTFail()
        } catch let error as OptionError {
            guard case let .validationError(option, message) = error.kind else {
                XCTFail()
                return
            }
            XCTAssertEqual(option, "-a")
            XCTAssertEqual(message, "Must be greater than 18")
        }
        
        let cmd4 = ValidatedKeyCmd()
        let arguments4 = ArgumentList(testString: "tester cmd -a 19")
        _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd4]), arguments: arguments4)
        XCTAssertEqual(cmd4.age.value, 19)
    }
    
    // MARK: - Combined test
    
    func testFullParse() throws {
        let cmd = TestCommand()
        let cli = CLI.createTester(commands: [cmd])
        
        let args = ArgumentList(arguments: ["test", "-s", "favTest", "-t", "3", "SwiftCLI"])
        let result = try Parser().parse(commandGroup: cli, arguments: args)
        
        XCTAssertTrue(result.command === cmd)
        
        XCTAssertEqual(cmd.testName.value, "favTest")
        XCTAssertEqual(cmd.testerName.value, "SwiftCLI")
        XCTAssertTrue(cmd.silent.value)
        XCTAssertEqual(cmd.times.value, 3)
    }
    
    func testCollectedOptions() throws {
        class RunCmd: Command {
            let name = "run"
            let executable = Parameter()
            let args = OptionalCollectedParameter()
            let verbose = Flag("-v")
            func execute() throws {}
        }
        
        let cmd = RunCmd()
        let cli = CLI.createTester(commands: [cmd])
        let args = ArgumentList(testString: "tester run cli -v arg")
        
        let result = try Parser().parse(commandGroup: cli, arguments: args)
        XCTAssertTrue(result.command === cmd)
        
        XCTAssertEqual(cmd.executable.value, "cli")
        XCTAssertEqual(cmd.args.value, ["-v", "arg"])
        XCTAssertFalse(cmd.verbose.value)
        
        let cmd2 = RunCmd()
        let cli2 = CLI.createTester(commands: [cmd2])
        let args2 = ArgumentList(testString: "tester run -v cli arg")
        
        let result2 = try Parser().parse(commandGroup: cli2, arguments: args2)
        XCTAssertTrue(result2.command === cmd2)
        
        XCTAssertEqual(cmd2.executable.value, "cli")
        XCTAssertEqual(cmd2.args.value, ["arg"])
        XCTAssertTrue(cmd2.verbose.value)
    }
    
}

extension ArgumentList {
    convenience init(testString: String) {
        self.init(argumentString: testString)
        pop()
    }
}
