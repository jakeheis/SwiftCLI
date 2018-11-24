import XCTest

import SwiftCLITests

var tests = [XCTestCaseEntry]()
tests += SwiftCLITests.__allTests()

XCTMain(tests)
