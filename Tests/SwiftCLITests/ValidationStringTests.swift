import XCTest
@testable import SwiftCLI

class ValidationStringTests: XCTestCase {
    static var allTests : [(String, (ValidationStringTests) -> () -> Void)] {
        return [
            ("testStringMinValidation", testStringMinValidation),
            ("testStringContainValidation", testStringContainValidation)
        ]
    }

    func testStringMinValidation() {
        let key = Key<String>("--key",
            description: "A key",
            validation: [.min(5)]
        )

        XCTAssertEqual(
            key.updateValue("A"),
            .validationError("Must be larger then 5"),
            "Should validate min length and fail"
        )

        XCTAssertEqual(
            key.updateValue("ABCDEF"),
            .succeeded,
            "Should validate min length and succeeded"
        )
    }

    func testStringContainValidation() {
        let key = Key<String>("--key",
            description: "A key",
            validation: [.contains("ABC")]
        )

        XCTAssertEqual(
            key.updateValue("DEF"),
            .validationError("Does not contain 'ABC'"),
            "Should validate substring"
        )

        XCTAssertEqual(
            key.updateValue("ABCDEF"),
            .succeeded,
            "Should validate sub string and succeed"
        )
    }

    func testStringMultiplyValidation() {
        let key = Key<String>("--key",
            description: "A key",
            validation: [.min(4), .contains("ABC")]
        )

        XCTAssertEqual(
            key.updateValue("ABCD"),
            .succeeded,
            "Should validate min length and sub string"
        )

        XCTAssertEqual(
            key.updateValue("ABC"),
            .validationError("Must be larger then 4"),
            "Should validate length"
        )

        XCTAssertEqual(
            key.updateValue("DEFG"),
            .validationError("Does not contain 'ABC'"),
            "Should check for substring"
        )
    }
}
