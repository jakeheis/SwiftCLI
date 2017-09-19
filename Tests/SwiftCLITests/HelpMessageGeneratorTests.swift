//
//  CommandMessageGeneratorTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class HelpMessageGeneratorTests: XCTestCase {
    
    static var allTests : [(String, (HelpMessageGeneratorTests) -> () throws -> Void)] {
        return [
            ("testCommandListGeneration", testCommandListGeneration),
            ("testUsageStatementGeneration", testUsageStatementGeneration),
            ("testMisusedOptionsStatementGeneration", testMisusedOptionsStatementGeneration)
        ]
    }
    
    let command = TestCommand()
    
    func testCommandListGeneration() {
        var message = DefaultHelpMessageGenerator().generateCommandList(prefix: "tester", description: "A tester for SwiftCLI", routables: [
            alphaCmd,
            betaCmd
        ])
        
        var expectedMessage = """
        
        Usage: tester <command> [options]
        
        A tester for SwiftCLI
        
        Commands:
          alpha           The alpha command
          beta            A beta command
        
        """
        
        XCTAssertEqual(message, expectedMessage)
        
        message = DefaultHelpMessageGenerator().generateCommandList(prefix: "tester", description: nil, routables: [
            alphaCmd,
            midGroup
        ])
        
        expectedMessage = """
        
        Usage: tester <command> [options]
        
        Groups:
          mid             The mid level of commands
        
        Commands:
          alpha           The alpha command
        
        """
        
        XCTAssertEqual(message, expectedMessage)
    }

    func testUsageStatementGeneration() {
        let cli = CLI(name: "tester")
        let message = DefaultHelpMessageGenerator().generateUsageStatement(for: command, in: cli)
        
        let expectedMessage = """
        
        Usage: tester test <testName> [<testerName>] [options]
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        """
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct usage statement")
    }
    
    func testMisusedOptionsStatementGeneration() {
        let arguments = ArgumentList(argumentString: "tester test -s -a --times")
        arguments.remove(node: arguments.head!)
        arguments.remove(node: arguments.head!)
        
        let cli = CLI(name: "tester")
        let registry = OptionRegistry(options: command.options(for: cli), optionGroups: command.optionGroups)
        
        do {
            try DefaultOptionRecognizer().recognizeOptions(from: registry, in: arguments)
            XCTFail("Option parser should fail on incorrectly used options")
        } catch let error as OptionRecognizerError {
            let message = DefaultHelpMessageGenerator().generateMisusedOptionsStatement(for: command, error: error, in: cli)
            
            let expectedMessage = """
            
            Usage: tester test <testName> [<testerName>] [options]
            
            Options:
              -h, --help             Show help information for this command
              -s, --silent           Silence all test output
              -t, --times <value>    Number of times to run the test
            
            Unrecognized option: -a

            """
            
            XCTAssertEqual(message, expectedMessage, "Should generate the correct misused options statement")
        } catch {}
    }

}
