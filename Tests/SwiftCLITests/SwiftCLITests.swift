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
    
    static var allTests : [(String, (SwiftCLITests) -> () throws -> Void)] {
        return [
            ("testCLIGo", testCLIGo),
            ("testCLIHelp", testCLIHelp),
            ("testGlobalOptions", testGlobalOptions),
            ("testOptionSplit", testOptionSplit)
        ]
    }
    
    var executionString = ""
    
    // Integration tests
    
    func testCLIGo() {
        let cli = createCLI()
        let result = cli.debugGo(with: "tester test firstTest MyTester -t 5 -s")
        XCTAssertEqual(result, 0, "Command should have succeeded")
        XCTAssertEqual(self.executionString, "MyTester will test firstTest, 5 times, silently", "Command should have produced accurate output")
    }
    
    func testCLIHelp() {
        let cli1 = createCLI()
        let result = cli1.debugGo(with: "tester help")
        XCTAssertEqual(result, 0, "Command should have succeeded")
        
        let cli2 = createCLI()
        let result2 = cli2.debugGo(with: "tester -h")
        XCTAssertEqual(result2, 0, "Command should have succeeded")
    }
    
    func testGlobalOptions() {
        let cli = createCLI()
        let verboseFlag = Flag("-v")
        cli.globalOptions.append(verboseFlag)
        
        let result3 = cli.debugGo(with: "tester test myTest -v")
        XCTAssertEqual(result3, 0, "Command should have succeeded")
        XCTAssertEqual(self.executionString, "defaultTester will test myTest, 1 times", "Command should have produced accurate output")
        XCTAssertTrue(verboseFlag.value)
    }
    
    func testOptionSplit() {
        let cli = createCLI()
        let result = cli.debugGo(with: "tester test firstTest MyTester -st 5")
        XCTAssertEqual(result, 0, "Command should have succeeded")
        XCTAssertEqual(self.executionString, "MyTester will test firstTest, 5 times, silently", "Command should have produced accurate output")
    }
    
    func createCLI() -> CLI {
        let cmd = TestCommand { (executionString) in
            self.executionString = executionString
        }
        return CLI.createTester(commands: [cmd])
    }
    
    // Tear down
    
    override func tearDown() {
        super.tearDown()
        
        executionString = ""
    }
    
}
