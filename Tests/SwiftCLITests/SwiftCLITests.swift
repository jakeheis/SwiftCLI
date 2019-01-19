//
//  SwiftCLITests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class SwiftCLITests: XCTestCase {
    
    private var executionString = ""
    
    // Integration tests
    
    func testGoWithArguments() {
        let (result, out, err) = runCLI { $0.go(with: ["test", "firstTest", "MyTester", "-t", "5", "-s"]) }
        XCTAssertEqual(result, 0, "Command should have succeeded")
        XCTAssertEqual(executionString, "MyTester will test firstTest, 5 times, silently", "Command should have produced accurate output")
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, "")
    }
    
    func testCLIHelp() {
        let (result, out, err) = runCLI { $0.go(with: ["help"]) }
        XCTAssertEqual(result, 0, "Command should have succeeded")
        XCTAssertEqual(out, """

        Usage: tester <command> [options]

        Commands:
          test            A command to test stuff
          help            Prints help information

        
        """)
        XCTAssertEqual(err, "")
        
        let (result2, out2, err2) = runCLI { $0.go(with: ["-h"]) }
        XCTAssertEqual(result2, 0, "Command should have succeeded")
        XCTAssertEqual(out2, """

        Usage: tester <command> [options]

        Commands:
          test            A command to test stuff
          help            Prints help information

        
        """)
        XCTAssertEqual(err2, "")
    }
    
    func testGlobalOptions() {
        let verboseFlag = Flag("-v")
        
        let (result, out, err) = runCLI {
            $0.globalOptions.append(verboseFlag)
            return $0.go(with: ["test", "myTest", "-v"])
        }
        XCTAssertEqual(result, 0, "Command should have succeeded")
        XCTAssertEqual(executionString, "defaultTester will test myTest, 1 times", "Command should have produced accurate output")
        XCTAssertTrue(verboseFlag.value)
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, "")
    }
    
    func testOptionSplit() {
        let (result, out, err) = runCLI { $0.go(with: ["test", "firstTest", "MyTester", "-st", "5"]) }
        XCTAssertEqual(result, 0, "Command should have succeeded")
        XCTAssertEqual(executionString, "MyTester will test firstTest, 5 times, silently", "Command should have produced accurate output")
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, "")
    }
    
    func testCommandHelp() {
        let (result, out, err) = runCLI { $0.go(with: ["test", "aTest", "-h"]) }
        XCTAssertEqual(result, 0)
        XCTAssertEqual(executionString, "")
        XCTAssertEqual(out, """
        
        Usage: tester test <testName> [<testerName>] [options]
        
        A command to test stuff
        
        Options:
          -h, --help             Show help information
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        

        """)
        XCTAssertEqual(err, "")
    }
    
    func testSingleCommand() {
        let cmd = TestCommand { (executionString) in
            self.executionString = executionString
        }
        let cli = CLI(singleCommand: cmd)
        XCTAssertEqual(cli.go(with: ["aTest"]), 0)
        XCTAssertEqual(executionString, "defaultTester will test aTest, 1 times")
    }
    
    private func runCLI(_ run: (CLI) -> Int32) -> (Int32, String, String) {
        let cmd = TestCommand { (executionString) in
            self.executionString = executionString
        }

        var result: Int32 = 0
        let (out, err) = CLI.capture {
            let cli = CLI.createTester(commands: [cmd])
            result = run(cli)
        }
        
        return (result, out, err)
    }
    
    // Tear down
    
    override func tearDown() {
        super.tearDown()
        
        executionString = ""
    }
    
}
