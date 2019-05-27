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
    
    func testManipulate() {
        let args = ArgumentList(arguments: ["tester", "test", "thisCase"])
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

