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
            ("testInheritedUsageStatementGeneration", testInheritedUsageStatementGeneration),
            ("testMisusedOptionsStatementGeneration", testMisusedOptionsStatementGeneration)
        ]
    }
    
    let command = TestCommand()
    
    func testCommandListGeneration() {
        let path = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, betaCmd], description: "A tester for SwiftCLI"))
        var message = DefaultHelpMessageGenerator().generateCommandList(for: path)
        
        var expectedMessage = """
        
        Usage: tester <command> [options]
        
        A tester for SwiftCLI
        
        Commands:
          alpha           The alpha command
          beta            A beta command
          help            Prints this help information
        
        """
        
        XCTAssertEqual(message, expectedMessage)
        
        let path2 = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, midGroup]))
        message = DefaultHelpMessageGenerator().generateCommandList(for: path2)
        
        expectedMessage = """
        
        Usage: tester <command> [options]
        
        Groups:
          mid             The mid level of commands
        
        Commands:
          alpha           The alpha command
          help            Prints this help information
        
        """
        
        XCTAssertEqual(message, expectedMessage)
    }

    func testUsageStatementGeneration() {
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        let message = DefaultHelpMessageGenerator().generateUsageStatement(for: path)
        
        let expectedMessage = """
        
        Usage: tester test <testName> [<testerName>] [options]
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        """
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct usage statement")
    }
    
    func testInheritedUsageStatementGeneration() {
        let cmd = TestInheritedCommand()
        let cli = CLI.createTester(commands: [cmd])
        let path = CommandGroupPath(top: cli).appending(cmd)
        let message = DefaultHelpMessageGenerator().generateUsageStatement(for: path)
        
        let expectedMessage = """
        
        Usage: tester test <testName> [<testerName>] [options]
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
          -v, --verbose          Show more output information
        
        """
        
        XCTAssertEqual(message, expectedMessage, "Should generate the correct usage statement")
    }
    
    func testMisusedOptionsStatementGeneration() {
        let arguments = ArgumentList(argumentString: "tester test -s -a --times")
        arguments.remove(node: arguments.head!)
        arguments.remove(node: arguments.head!)
        
        let cli = CLI.createTester(commands: [command])
        let registry = OptionRegistry(options: command.options, optionGroups: command.optionGroups)
        
        do {
            try DefaultOptionRecognizer().recognizeOptions(from: registry, in: arguments)
            XCTFail("Option parser should fail on incorrectly used options")
        } catch let error as OptionRecognizerError {
            let path = CommandGroupPath(top: cli).appending(command)
            let message = DefaultHelpMessageGenerator().generateMisusedOptionsStatement(for: path, error: error)
            
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
