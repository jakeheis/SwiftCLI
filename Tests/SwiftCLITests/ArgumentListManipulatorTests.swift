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
    
    func testOptionSplitter() {
        let splitter = OptionSplitter()
        
        let args = ArgumentList(arguments: ["tester", "-ab"])
        splitter.manipulate(arguments: args)
        XCTAssertEqual(args.pop(), "tester")
        XCTAssertEqual(args.pop(), "-a")
        XCTAssertEqual(args.pop(), "-b")
        XCTAssertFalse(args.hasNext())
    }
    
    func testEqualsSplit() {
        let splitter = OptionSplitter()
        
        let args = ArgumentList(arguments: ["tester", "--key=value"])
        splitter.manipulate(arguments: args)
        XCTAssertEqual(args.pop(), "tester")
        XCTAssertEqual(args.pop(), "--key")
        XCTAssertEqual(args.pop(), "value")
        XCTAssertFalse(args.hasNext())
    }
    
}
