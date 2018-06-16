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
            ("testLongDescriptionGeneration", testLongDescriptionGeneration),
            ("testInheritedUsageStatementGeneration", testInheritedUsageStatementGeneration),
            ("testMisusedOptionsStatementGeneration", testMisusedOptionsStatementGeneration),
            ("testNoCommandMisusedOption", testNoCommandMisusedOption),
            ("testMutlineUsageStatementGeneration", testMutlineUsageStatementGeneration),
            ("testMutlineCommandListGeneration", testMutlineCommandListGeneration)
        ]
    }
    
    func testCommandListGeneration() {
        let capture = CaptureStream()
        let path = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, betaCmd], description: "A tester for SwiftCLI"))
        DefaultHelpMessageGenerator().writeCommandList(for: path, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester <command> [options]
        
        A tester for SwiftCLI
        
        Commands:
          alpha           The alpha command
          beta            A beta command
          help            Prints this help information
        
        
        """)
        
        let capture2 = CaptureStream()
        let path2 = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, midGroup]))
        DefaultHelpMessageGenerator().writeCommandList(for: path2, to: capture2)
        capture2.closeWrite()
        
        XCTAssertEqual(capture2.readAll(), """
        
        Usage: tester <command> [options]
        
        Groups:
          mid             The mid level of commands
        
        Commands:
          alpha           The alpha command
          help            Prints this help information
        
        
        """)
    }

    func testUsageStatementGeneration() {
        let capture = CaptureStream()
        let command = TestCommand()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]

        A command to test stuff
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        
        """)
    }

    func testLongDescriptionGeneration() {
        let capture = CaptureStream()
        let command = TestCommandWithLongDescription()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: capture)
        capture.closeWrite()

        XCTAssertEqual(capture.readAll(), """

        Usage: tester test [options]

        This is a long
        multiline description

        Options:
          -h, --help      Show help information for this command


        """)
    }
    
    func testInheritedUsageStatementGeneration() {
        let capture = CaptureStream()
        let cmd = TestInheritedCommand()
        let cli = CLI.createTester(commands: [cmd])
        let path = CommandGroupPath(top: cli).appending(cmd)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]

        A command to test stuff
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
          -v, --verbose          Show more output information
        

        """)
    }
    
    func testMisusedOptionsStatementGeneration() {
        let capture = CaptureStream()
        let command = TestCommand()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: OptionError(command: path, message: "Unrecognized option: -a"), to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]

        A command to test stuff
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        Unrecognized option: -a
        
        
        """)
    }
    
    func testNoCommandMisusedOption() {
        let capture = CaptureStream()
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: OptionError(command: nil, message: "Unrecognized option: -a"), to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Unrecognized option: -a
        
        
        """)
    }

    func testMutlineUsageStatementGeneration() {
        let capture = CaptureStream()
        let command = MultilineCommand()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: capture)
        capture.closeWrite()

        XCTAssertEqual(capture.readAll(), """

        Usage: tester test [options]

        A command that has multiline comments.
        New line

        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
                                 Newline
          -t, --times <value>    Number of times to run the test


        """)
    }

    func testMutlineCommandListGeneration() {
        let capture = CaptureStream()
        let path = CommandGroupPath(top: CLI.createTester(commands: [MultilineCommand(), betaCmd], description: "A tester for SwiftCLI"))
        DefaultHelpMessageGenerator().writeCommandList(for: path, to: capture)
        capture.closeWrite()

        XCTAssertEqual(capture.readAll(), """

        Usage: tester <command> [options]

        A tester for SwiftCLI

        Commands:
          test            A command that has multiline comments.
                          New line
          beta            A beta command
          help            Prints this help information


        """)
    }

}
