//
//  InputTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 3/15/18.
//

import XCTest
@testable import SwiftCLI

class InputTests: XCTestCase {
    
    private var input: [String] = []

    override func setUp() {
        super.setUp()

        ReadInput.read = {
            return self.input.removeFirst()
        }
    }
    
    func testInt() {
        input = ["asdf", "3.4", "5"]
        let (out, err) = CLI.capture {
            let int = Input.readInt()
            XCTAssertEqual(int, 5)
        }
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, """
        Invalid value; expected Int
        Invalid value; expected Int
        
        """)
    }
    
    func testDouble() {
        input = ["asdf", "3.4", "5"]
        let (out, err) = CLI.capture {
            let double = Input.readDouble()
            XCTAssertEqual(double, 3.4)
        }
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, """
        Invalid value; expected Double
        
        """)
    }
    
    func testBool() {
        input = ["asdf", "5", "false"]
        let (out, err) = CLI.capture {
            let bool = Input.readBool()
            XCTAssertEqual(bool, false)
        }
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, """
        Invalid value; expected Bool
        Invalid value; expected Bool

        """)
        
        input = ["asdf", "5", "T"]
        let (out2, err2) = CLI.capture {
            let bool = Input.readBool()
            XCTAssertEqual(bool, true)
        }
        XCTAssertEqual(out2, "")
        XCTAssertEqual(err2, """
        Invalid value; expected Bool
        Invalid value; expected Bool

        """)
        
        input = ["asdf", "yeppp", "YES"]
        let (out3, err3) = CLI.capture {
            let bool = Input.readBool()
            XCTAssertEqual(bool, true)
        }
        XCTAssertEqual(out3, "")
        XCTAssertEqual(err3, """
        Invalid value; expected Bool
        Invalid value; expected Bool

        """)
    }
    
    func testValidation() {
        input = ["asdf", "3.4", "5", "9", "11"]
        let (out, err) = CLI.capture {
            let int = Input.readInt(validation: [.greaterThan(10)])
            XCTAssertEqual(int, 11)
        }
        XCTAssertEqual(out, "")
        XCTAssertEqual(err, """
        Invalid value; expected Int
        Invalid value; expected Int
        Invalid value; must be greater than 10
        Invalid value; must be greater than 10

        """)
        
        input = ["asdf", "5", "false", "SwiftCLI"]
        let (out2, err2) = CLI.capture {
            let str = Input.readLine(validation: [.contains("ift")])
            XCTAssertEqual(str, "SwiftCLI")
        }
        XCTAssertEqual(out2, "")
        XCTAssertEqual(err2, """
        Invalid value; must contain 'ift'
        Invalid value; must contain 'ift'
        Invalid value; must contain 'ift'

        """)
    }

}
