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
            ("testGlobalOptions", testGlobalOptions)
        ]
    }
    
    lazy var internalCli: CLI? = {
        let cmd = TestCommand { (executionString) in
            self.executionString = executionString
        }
        return CLI(name: "tester", commands: [cmd])
    }()
    var cli: CLI {
        return internalCli!
    }
    
    var executionString = ""
    
    // Integration test
    
    func testCLIGo() {
        let result = cli.debugGo(with: "tester test firstTest MyTester -t 5 -s")
        XCTAssertEqual(result, 0, "Command should have succeeded")
        XCTAssertEqual(self.executionString, "MyTester will test firstTest, 5 times, silently", "Command should have produced accurate output")
    }
    
    func testCLIHelp() {
        let result = cli.debugGo(with: "tester help")
        XCTAssertEqual(result, 0, "Command should have succeeded")
        
        let result2 = cli.debugGo(with: "tester -h")
        XCTAssertEqual(result2, 0, "Command should have succeeded")
    }
    
    func testGlobalOptions() {
        GlobalOptions.source(MyGlobalOptions.self)
        let result3 = cli.debugGo(with: "tester test myTest -v")
        XCTAssertEqual(result3, 0, "Command should have succeeded")
        XCTAssertEqual(self.executionString, "defaultTester will test myTest, 1 times, verbosely", "Command should have produced accurate output")

    }
    
    // Tear down
    
    override func tearDown() {
        super.tearDown()
        
        executionString = ""
    }
    
}

struct MyGlobalOptions: GlobalOptionsSource {
    static let verbose = Flag("-v")
    static var options: [Option] {
        return [verbose]
    }
}

extension Command {
    var verbose: Flag {
        return MyGlobalOptions.verbose
    }
}
