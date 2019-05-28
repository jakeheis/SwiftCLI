//
//  ValidationTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 11/23/18.
//

import XCTest
import SwiftCLI

class ValidationTests: XCTestCase {

    func testEquatable() {
        let allow = Validation.allowing("this", "that")
        assertFailure(of: allow, with: "something", message: "must be one of: this, that")
        assertSuccess(of: allow, with: "this")
        assertSuccess(of: allow, with: "that")
        
        let reject = Validation.rejecting("this", "that")
        assertFailure(of: reject, with: "this", message: "must not be: this, that")
        assertFailure(of: reject, with: "that", message: "must not be: this, that")
        assertSuccess(of: reject, with: "something")
    }
    
    func testComparable() {
        let greaterThan = Validation.greaterThan(18)
        assertFailure(of: greaterThan, with: 15, message: "must be greater than 18")
        assertSuccess(of: greaterThan, with: 19)
        
        let lessThan = Validation.lessThan(18)
        assertFailure(of: lessThan, with: 19, message: "must be less than 18")
        assertSuccess(of: lessThan, with: 15)
        
        let withinClosed = Validation.within(18...30)
        assertFailure(of: withinClosed, with: 15, message: "must be greater than or equal to 18 and less than or equal to 30")
        assertFailure(of: withinClosed, with: 31, message: "must be greater than or equal to 18 and less than or equal to 30")
        assertSuccess(of: withinClosed, with: 18)
        assertSuccess(of: withinClosed, with: 24)
        assertSuccess(of: withinClosed, with: 30)
        
        let withinHalfOpen = Validation.within(18..<30)
        assertFailure(of: withinHalfOpen, with: 15, message: "must be greater than or equal to 18 and less than 30")
        assertFailure(of: withinHalfOpen, with: 30, message: "must be greater than or equal to 18 and less than 30")
        assertFailure(of: withinHalfOpen, with: 31, message: "must be greater than or equal to 18 and less than 30")
        assertSuccess(of: withinHalfOpen, with: 18)
        assertSuccess(of: withinHalfOpen, with: 24)
    }
    
    func testString() {
        let contains = Validation.contains("hi")
        assertFailure(of: contains, with: "that", message: "must contain 'hi'")
        assertSuccess(of: contains, with: "this")
    }
    
    private func assertSuccess<T>(of validation: Validation<T>, with input: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(validation.validate(input), file: file, line: line)
    }
    
    private func assertFailure<T>(of validation: Validation<T>, with input: T, message expectedMessage: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(validation.validate(input), file: file, line: line)
        XCTAssertEqual(validation.message, expectedMessage, file: file, line: line)
    }
    
}
