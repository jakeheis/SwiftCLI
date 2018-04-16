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
    
    func testCommandListGeneration() {
        let pipe = PipeStream()
        let path = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, betaCmd], description: "A tester for SwiftCLI"))
        DefaultHelpMessageGenerator().writeCommandList(for: path, to: pipe)
        pipe.closeWrite()
        
        XCTAssertEqual(pipe.readAll(), """
        
        Usage: tester <command> [options]
        
        A tester for SwiftCLI
        
        Commands:
          alpha           The alpha command
          beta            A beta command
          help            Prints this help information
        
        """)
        
        let pipe2 = PipeStream()
        let path2 = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, midGroup]))
        DefaultHelpMessageGenerator().writeCommandList(for: path2, to: pipe2)
        pipe2.closeWrite()
        
        XCTAssertEqual(pipe2.readAll(), """
        
        Usage: tester <command> [options]
        
        Groups:
          mid             The mid level of commands
        
        Commands:
          alpha           The alpha command
          help            Prints this help information
        
        """)
    }

    func testUsageStatementGeneration() {
        let pipe = PipeStream()
        let command = TestCommand()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: pipe)
        pipe.closeWrite()
        
        XCTAssertEqual(pipe.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        """)
    }
    
    func testInheritedUsageStatementGeneration() {
        let pipe = PipeStream()
        let cmd = TestInheritedCommand()
        let cli = CLI.createTester(commands: [cmd])
        let path = CommandGroupPath(top: cli).appending(cmd)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: pipe)
        pipe.closeWrite()
        
        XCTAssertEqual(pipe.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
          -v, --verbose          Show more output information
        
        """)
    }
    
    func testMisusedOptionsStatementGeneration() {
        let pipe = PipeStream()
        let command = TestCommand()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: OptionError(command: path, message: "Unrecognized option: -a"), to: pipe)
        pipe.closeWrite()
        
        XCTAssertEqual(pipe.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]
        
        Options:
          -h, --help             Show help information for this command
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        Unrecognized option: -a
        
        """)
    }

}
