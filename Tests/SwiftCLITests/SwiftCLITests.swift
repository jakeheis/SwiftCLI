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
        XCTAssertEqual(result2, 1, "Command should have failed")
        XCTAssertEqual(err2, """

        Usage: tester <command> [options]

        Commands:
          test            A command to test stuff
          help            Prints help information

        
        """)
        XCTAssertEqual(out2, "")
    }
    
    func testGlobalOptions() {
        let verboseFlag = Flag("-v")
        
        let (result, out, err) = runCLI {
            $0.globalOptions.append(verboseFlag)
            return $0.go(with: ["test", "myTest", "-v"])
        }
        XCTAssertEqual(result, 0, "Command should have succeeded")
        XCTAssertEqual(executionString, "defaultTester will test myTest, 1 times", "Command should have produced accurate output")
        XCTAssertTrue(verboseFlag.wrappedValue)
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
        let cmd = RememberExecutionCmd()
        let cli = CLI(singleCommand: cmd)
        
        let (out, err) = CLI.capture {
            let result = cli.go(with: ["aTest"])
            XCTAssertEqual(result, 0)
        }
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, "")
        XCTAssertTrue(cmd.executed)
        XCTAssertEqual(cmd.param, "aTest")

        let cmd2 = RememberExecutionCmd()
        let cli2 = CLI(singleCommand: cmd2)
        
        let (out2, err2) = CLI.capture {
            let result = cli2.go(with: [])
            XCTAssertEqual(result, 0)
        }
        XCTAssertEqual(out2, "")
        XCTAssertEqual(err2, "")
        XCTAssertTrue(cmd2.executed)
        XCTAssertNil(cmd2.param)
        
        let cmd3 = RememberExecutionCmd()
        let cli3 = CLI(singleCommand: cmd3)
        
        let (out3, err3) = CLI.capture {
            let result = cli3.go(with: ["-h"])
            XCTAssertEqual(result, 0)
        }
        XCTAssertEqual(out3, """
        
        Usage: cmd [<param>] [options]

        Remembers execution

        Options:
          -h, --help      Show help information
        
        
        """)
        XCTAssertEqual(err3, "")
    }
    
    func testFallback() {
        class Execute: Command {
            let name = "execute"
            @OptParam var file: String?
            var executed = false
            func execute() throws { executed = true }
        }
        
        class Build: Command {
            let name = "build"
            var built = false
            func execute() throws { built = true }
        }
        
        let execute1 = Execute()
        let build1 = Build()
        
        let (out, err) = CLI.capture {
            let cli = CLI(name: "swift", commands: [build1])
            cli.parser.routeBehavior = .searchWithFallback(execute1)
            let result = cli.go(with: ["build"])
            XCTAssertEqual(result, 0)
        }
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, "")
        XCTAssertTrue(build1.built)
        XCTAssertFalse(execute1.executed)
        XCTAssertNil(execute1.file)
        
        let execute2 = Execute()
        let build2 = Build()
        
        let (out2, err2) = CLI.capture {
            let cli = CLI(name: "swift", commands: [build2])
            cli.parser.routeBehavior = .searchWithFallback(execute2)
            let result = cli.go(with: ["file.swift"])
            XCTAssertEqual(result, 0)
        }
        XCTAssertEqual(out2, "")
        XCTAssertEqual(err2, "")
        XCTAssertFalse(build2.built)
        XCTAssertTrue(execute2.executed)
        XCTAssertEqual(execute2.file, "file.swift")
        
        let execute3 = Execute()
        let build3 = Build()
        
        let (out3, err3) = CLI.capture {
            let cli = CLI(name: "swift", commands: [build3])
            cli.parser.routeBehavior = .searchWithFallback(execute3)
            let result = cli.go(with: [])
            XCTAssertEqual(result, 0)
        }
        XCTAssertEqual(out3, "")
        XCTAssertEqual(err3, "")
        XCTAssertFalse(build3.built)
        XCTAssertTrue(execute3.executed)
        XCTAssertNil(execute3.file)
        
        let execute4 = Execute()
        let build4 = Build()
        
        let (out4, err4) = CLI.capture {
            let cli = CLI(name: "swift", commands: [build4])
            cli.parser.routeBehavior = .searchWithFallback(execute4)
            let result = cli.go(with: ["-h"])
            XCTAssertEqual(result, 0)
        }
        XCTAssertEqual(out4, """
        
        Usage: swift [<file>] [options]

        Options:
          -h, --help      Show help information
        
        
        """)
        XCTAssertEqual(err4, "")
        
        let execute5 = Execute()
        let build5 = Build()
        
        let (out5, err5) = CLI.capture {
            let cli = CLI(name: "swift", commands: [build5])
            cli.parser.routeBehavior = .searchWithFallback(execute5)
            let result = cli.go(with: ["hi.swift", "this.swift"])
            XCTAssertEqual(result, 1)
        }
        XCTAssertEqual(err5, """
        
        Usage: swift [<file>] [options]

        Options:
          -h, --help      Show help information
        
        Error: command requires between 0 and 1 arguments

        
        """)
        XCTAssertEqual(out5, "")
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
