//
//  SwiftCLITests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCLI

class SwiftCLITests: XCTestCase {
    
    static var allTests : [(String, (SwiftCLITests) -> () throws -> Void)] {
        return [
            ("testCLIGo", testCLIGo),
            ("testCLIHelp", testCLIHelp)
        ]
    }
    
    var executionString = ""
    
    override func setUp() {
        super.setUp()
        
        CLI.setup(name: "tester")
        CLI.register(command: TestCommand {(executionString) in
            self.executionString = executionString
        })
    }
    
    // Integration test
    
    func testCLIGo() {
        let result = CLI.debugGo(with: "tester test firstTest MyTester -t 5 -s")
        XCTAssertEqual(result, CLIResult.success, "Command should have succeeded")
        XCTAssertEqual(self.executionString, "MyTester will test firstTest, 5 times, silently", "Command should have produced accurate output")
    }
    
    func testCLIHelp() {
        let result = CLI.debugGo(with: "tester help")
        XCTAssertEqual(result, CLIResult.success, "Command should have succeeded")
        
        let result2 = CLI.debugGo(with: "tester -h")
        XCTAssertEqual(result2, CLIResult.success, "Command should have succeeded")
    }
    
    // Tear down
    
    override func tearDown() {
        super.tearDown()
        
        executionString = ""
    }
    
}
