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

func createTestCommand(completion: ((executionString: String) -> ())? = nil) -> OptionCommandType {
    var silentFlag = false
    var times: Int = 1
    var executionString = ""
    
    return ChainableCommand(commandName: "test")
        .withSignature("<testName> [<testerName>]")
        .withOptionsSetup {(options) in
            options.add(flags: ["-s", "--silent"], usage: "Silence all test output") {(flag) in
                silentFlag = true
            }
            options.add(keys: ["-t", "--times"], usage: "Number of times to run the test", valueSignature: "times") {(key, value) in
                times = Int(value)!
            }
        }
        .withExecutionBlock {(arguments) in
            let testName = arguments.requiredArgument("testName")
            let testerName = arguments.optionalArgument("testerName") ?? "Tester"
            executionString = "\(testerName) will test \(testName), \(times) times"
            if silentFlag {
                executionString += ", silently"
            }
            
            completion?(executionString: executionString)
    }
}

class SwiftCLITests: XCTestCase {
    
    var executionString = ""
    
    override func setUp() {
        super.setUp()
        
        CLI.setup(name: "tester")
        CLI.register(command: createTestCommand {(executionString) in
            self.executionString = executionString
        })
    }
    
    // Integration test
    
    func testCLIGo() {
        let result = CLI.debugGo(with: "tester test firstTest MyTester -t 5 -s")
        XCTAssertEqual(result, CLIResult.Success, "Command should have succeeded")
        XCTAssertEqual(self.executionString, "MyTester will test firstTest, 5 times, silently", "Command should have produced accurate output")
    }
    
    // Tear down
    
    override func tearDown() {
        super.tearDown()
        
        executionString = ""
    }
    
}
