//
//  InputTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 3/15/18.
//

import XCTest
@testable import SwiftCLI

class InputTests: XCTestCase {
    
    static var allTests : [(String, (InputTests) -> () throws -> Void)] {
        return [
            ("testInt", testInt),
            ("testDouble", testDouble),
            ("testBool", testBool)
        ]
    }
    
    var input: [String] = []

    override func setUp() {
        super.setUp()

        ReadInput.read = {
            return self.input.removeFirst()
        }
    }
    
    func testInt() {
        input = ["asdf", "3.4", "5"]
        let int = Input.readInt()
        XCTAssertEqual(int, 5)
    }
    
    func testDouble() {
        input = ["asdf", "3.4", "5"]
        let double = Input.readDouble()
        XCTAssertEqual(double, 3.4)
    }
    
    func testBool() {
        input = ["asdf", "5", "false"]
        let bool = Input.readBool()
        XCTAssertEqual(bool, false)
        
        input = ["asdf", "5", "T"]
        let bool2 = Input.readBool()
        XCTAssertEqual(bool2, true)
        
        input = ["asdf", "yeppp", "YES"]
        let bool3 = Input.readBool()
        XCTAssertEqual(bool3, true)
    }
    
    func testValidation() {
        input = ["asdf", "3.4", "5", "9", "11"]
        let int = Input.readInt(validation: [.greaterThan(10)])
        XCTAssertEqual(int, 11)
        
        input = ["asdf", "5", "false", "SwiftCLI"]
        let str = Input.readLine(validation: [.contains("ift")])
        XCTAssertEqual(str, "SwiftCLI")
    }

}
