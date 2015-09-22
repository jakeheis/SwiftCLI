//
//  CommandMessageGeneratorTests.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import XCTest

class CommandMessageGeneratorTests: XCTestCase {
    
    var command: OptionCommandType!

    override func setUp() {
        super.setUp()

        command = createTestCommand()
        
        CLI.setup(name: "tester")
    }

    func testUsageStatementGeneration() {
        let options = Options()
        command.internalSetupOptions(options)
        
        let message = CommandMessageGenerator.generateUsageStatement(command: command, options: options)
        
        let expectedMessage = ([
            "Usage: tester test <testName> [<testerName>] [options]",
            "",
            "-h, --help                               Show help information for this command",
            "-s, --silent                             Silence all test output",
            "-t, --times <times>                      Number of times to run the test",
            ""
        ]).joinWithSeparator("\n")
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct usage statement")
    }
    
    func testMisusedOptionsStatementGeneration() {
        let options = Options()
        command.internalSetupOptions(options)
        
        let arguments = RawArguments(argumentString: "tester test -s -a --times")
        arguments.classifyArgument(argument: "tester", type: .AppName)
        arguments.classifyArgument(argument: "test", type: .CommandName)
        options.recognizeOptionsInArguments(arguments)
        
        let message = CommandMessageGenerator.generateMisusedOptionsStatement(command: command, options: options)!
        
        let expectedMessage = ([
            "Usage: tester test <testName> [<testerName>] [options]",
            "",
            "-h, --help                               Show help information for this command",
            "-s, --silent                             Silence all test output",
            "-t, --times <times>                      Number of times to run the test",
            "",
            "Unrecognized options:",
            "\t-a",
            "Required values for options but given none:",
            "\t--times",
            ""
        ]).joinWithSeparator("\n")
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct misused options statement")
    }

}
