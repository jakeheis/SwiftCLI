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
            ("testOptionSplitter", testOptionSplitter)
        ]
    }
    
    func testCommandAliaser() {
        assertManipulation(start: "tester -h", manipulator: CommandAliaser(), end: "tester help")
        
        CommandAliaser.alias(from: "-a", to: "alpha")
        assertManipulation(start: "tester -a", manipulator: CommandAliaser(), end: "tester alpha")
        
        CommandAliaser.removeAlias(from: "-a")
        assertManipulation(start: "tester -a", manipulator: CommandAliaser(), end: "tester -a")
    }
    
    func testOptionSplitter() {
        let splitter = OptionSplitter()
        assertManipulation(start: "tester -ab", manipulator: splitter, end: "tester -a -b")
    }
    
    func assertManipulation(start: String, manipulator: ArgumentListManipulator, end: String) {
        let arguments = ArgumentList(argumentString: start)
        manipulator.manipulate(arguments: arguments)
        let finish = "tester " + IteratorSequence(arguments.iterator()).map({ $0.value }).joined(separator: " ")
        XCTAssert(finish == end, "Manipulator manipulated incorrectly")
    }
    
}
