//
//  ArgumentListTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/29/17.
//
//

import XCTest
@testable import SwiftCLI

class ArgumentListTests: XCTestCase {
    
    static var allTests : [(String, (ArgumentListTests) -> () throws -> Void)] {
        return [
            ("testStringParse", testStringParse),
            ("testManipulate", testManipulate),
        ]
    }
    
    func testStringParse() {
        let easy = ArgumentList(argumentString: "tester test thisCase")
        XCTAssertEqual(easy.pop(), "tester")
        XCTAssertEqual(easy.pop(), "test")
        XCTAssertEqual(easy.pop(), "thisCase")
        XCTAssertFalse(easy.hasNext())
        
        let doubleQuote = ArgumentList(argumentString: "tester \"hi\" \"hello\"")
        XCTAssertEqual(doubleQuote.pop(), "tester")
        XCTAssertEqual(doubleQuote.pop(), "hi")
        XCTAssertEqual(doubleQuote.pop(), "hello")
        XCTAssertFalse(doubleQuote.hasNext())
        
        let singleQuote = ArgumentList(argumentString: "tester \"hi hello\"")
        XCTAssertEqual(singleQuote.pop(), "tester")
        XCTAssertEqual(singleQuote.pop(), "hi hello")
        XCTAssertFalse(easy.hasNext())
    }
    
    func testManipulate() {
        let args = ArgumentList(argumentString: "tester test thisCase")
        args.manipulate { (args) in
            return args.map { $0.uppercased() } + ["last"]
        }
        
        XCTAssertEqual(args.pop(), "TESTER")
        XCTAssertEqual(args.pop(), "TEST")
        XCTAssertEqual(args.pop(), "THISCASE")
        XCTAssertEqual(args.pop(), "last")
        XCTAssertFalse(args.hasNext())
    }
    
}

