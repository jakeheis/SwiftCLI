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
        let message = DefaultUsageStatementGenerator().generateUsageStatement(for: command)
        
        let expectedMessage = ([
            "Usage: tester test <testName> [<testerName>] [options]",
            "",
            "-h, --help                              Show help information for this command",
            "-s, --silent                            Silence all test output",
            "-t, --times <value>                     Number of times to run the test",
            ""
        ]).joined(separator: "\n")
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct usage statement")
    }
    
    func testMisusedOptionsStatementGeneration() {
        let optionRegistry = OptionRegistry(command: command)
        
        let arguments = ArgumentList(argumentString: "tester test -s -a --times")
        arguments.remove(node: arguments.head!)
        arguments.remove(node: arguments.head!)
        
        do {
            try DefaultOptionParser().recognizeOptions(in: arguments, from: optionRegistry)
            XCTFail("Option parser should fail on incorrectly used options")
        } catch let error as OptionParserError {
            let message = DefaultMisusedOptionsMessageGenerator().generateMisusedOptionsStatement(for: command, error: error)
            
            let expectedMessage = ([
                "Usage: tester test <testName> [<testerName>] [options]",
                "",
                "-h, --help                              Show help information for this command",
                "-s, --silent                            Silence all test output",
                "-t, --times <value>                     Number of times to run the test",
                "",
                "Unrecognized option: -a"
                ]).joined(separator: "\n")
            
            XCTAssertEqual(message, expectedMessage, "Should generate the correct misused options statement")
        } catch {}
    }

}
