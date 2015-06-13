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
    }

    func testUsageStatementGeneration() {
        let options = Options()
        command.setupOptions(options)
        
        let message = CommandMessageGenerator.generateUsageStatement(command: command, routedName: nil, options: options)
        
        let expectedMessage = "\n".join([
            "Usage:  test <testName> [<testerName>] [options]",
            "",
            "-h, --help                               Show help information for this command",
            "-s, --silent                             Silence all test output",
            "-t, --times <times>                      Number of times to run the test",
            ""
        ])
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct usage statement")
    }

}
