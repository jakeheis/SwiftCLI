//
//  CommandMessageGeneratorTests.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class CommandMessageGeneratorTests: XCTestCase {
    
    static var allTests : [(String, (CommandMessageGeneratorTests) -> () throws -> Void)] {
        return [
            ("testUsageStatementGeneration", testUsageStatementGeneration),
            ("testMisusedOptionsStatementGeneration", testMisusedOptionsStatementGeneration)
        ]
    }
    
    let command = TestCommand()

    override func setUp() {
        super.setUp()
        
        CLI.setup(name: "tester")
    }

    func testUsageStatementGeneration() {
        let optionRegistry = OptionRegistry()
        command.internalSetupOptions(options: optionRegistry)
        
        let message = DefaultUsageStatementGenerator().generateUsageStatement(for: command, optionRegistry: optionRegistry)
        
        let expectedMessage = ([
            "Usage: tester test <testName> [<testerName>] [options]",
            "",
            "-h, --help                              Show help information for this command",
            "-s, --silent                            Silence all test output",
            "-t, --times <times>                     Number of times to run the test",
            ""
        ]).joined(separator: "\n")
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct usage statement")
    }
    
    func testMisusedOptionsStatementGeneration() {
        let optionRegistry = OptionRegistry()
        command.internalSetupOptions(options: optionRegistry)
        
        let arguments = RawArguments(argumentString: "tester test -s -a --times")
        arguments.unclassifiedArguments.first?.classification = .appName
        arguments.unclassifiedArguments.first?.classification = .commandName
        
        let result = DefaultOptionParser().recognizeOptions(in: arguments, from: optionRegistry)
        
        guard case let .incorrectOptionUsage(incorrectOptionUsage) = result else {
            XCTFail("Option parser should fail on incorrectly used options")
            return
        }
        
        let message = DefaultMisusedOptionsMessageGenerator().generateMisusedOptionsStatement(for: command, incorrectOptionUsage: incorrectOptionUsage)!
        
        let expectedMessage = ([
            "Usage: tester test <testName> [<testerName>] [options]",
            "",
            "-h, --help                              Show help information for this command",
            "-s, --silent                            Silence all test output",
            "-t, --times <times>                     Number of times to run the test",
            "",
            "Unrecognized options:",
            "\t-a",
            "Required values for options but given none:",
            "\t--times",
            ""
        ]).joined(separator: "\n")
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct misused options statement")
    }

}
