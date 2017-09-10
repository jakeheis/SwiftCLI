//
//  ArgumentListManipulatorTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/29/17.
//
//

import XCTest
@testable import SwiftCLI

class ArgumentListManipulatorTests: XCTestCase {
    
    static var allTests : [(String, (ArgumentListManipulatorTests) -> () throws -> Void)] {
        return [
            ("testCommandAliaser", testCommandAliaser),
            ("testOptionSplitter", testOptionSplitter),
            ("testEqualsSplit", testEqualsSplit)
        ]
    }
    
    func testCommandAliaser() {
        var result = assertManipulation(start: "tester -h", manipulator: CommandAliaser())
        XCTAssertEqual(result, "tester help")
        
        CommandAliaser.alias(from: "-a", to: "alpha")
        result = assertManipulation(start: "tester -a", manipulator: CommandAliaser())
        XCTAssertEqual(result, "tester alpha")
        
        CommandAliaser.removeAlias(from: "-a")
        result = assertManipulation(start: "tester -a", manipulator: CommandAliaser())
        XCTAssertEqual(result, "tester -a")
    }
    
    func testOptionSplitter() {
        let splitter = OptionSplitter()
        let result = assertManipulation(start: "tester -ab", manipulator: splitter)
        XCTAssertEqual(result, "tester -a -b")
    }
    
    func testEqualsSplit() {
        let splitter = OptionSplitter()
        
        var result = assertManipulation(start: "tester --key=value", manipulator: splitter)
        XCTAssertEqual(result, "tester --key value")
        
        result = assertManipulation(start: "tester --key value", manipulator: splitter)
        XCTAssertEqual(result, "tester --key value")
    }
    
    func assertManipulation(start: String, manipulator: ArgumentListManipulator) -> String {
        let arguments = ArgumentList(argumentString: start)
        manipulator.manipulate(arguments: arguments)
        return "tester " + IteratorSequence(arguments.iterator()).map({ $0.value }).joined(separator: " ")
    }
    
}
