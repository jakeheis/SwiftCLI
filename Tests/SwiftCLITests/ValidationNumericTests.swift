import XCTest
@testable import SwiftCLI

class ValidationNumericTests: XCTestCase {
    static var allTests : [(String, (ValidationNumericTests) -> () -> Void)] {
        return [
            ("testIntMinValidation", testIntMinValidation),
            ("testFloatMinValidation", testFloatMinValidation),
            ("testIntMaxValidation", testIntMaxValidation),
            ("testFloatMaxValidation", testFloatMaxValidation),
            ("testIntWithinValidation", testIntWithinValidation),
            ("testFloatWithinValidation", testFloatWithinValidation)
        ]
    }

    func testIntMinValidation() {
        let key = Key<Int>("--key",
            description: "A key",
            validation: [.min(5)]
        )

        XCTAssertEqual(
            key.updateValue("3"),
            .validationError("Must be larger then 5"),
            "Should validate min value and fail"
        )

        XCTAssertEqual(
            key.updateValue("7"),
            .succeeded,
            "Should validate min value and succeed"
        )

    }

    func testIntMaxValidation() {
        let key = Key<Int>("--key",
            description: "A key",
            validation: [.max(5)]
        )

        XCTAssertEqual(
            key.updateValue("10"),
            .validationError("Must be smaller then 5"),
            "Should validate max value and fail"
        )

        XCTAssertEqual(
            key.updateValue("3"),
            .succeeded,
            "Should validate max value and succeed"
        )

    }

    func testFloatMinValidation() {
        let key = Key<Float>("--key",
            description: "A key",
            validation: [.min(5.0)]
        )

        XCTAssertEqual(
            key.updateValue("3"),
            .validationError("Must be larger then 5.0"),
            "Should validate min value and fail"
        )

        XCTAssertEqual(
            key.updateValue("7.0"),
            .succeeded,
            "Should validate min value and succeed"
        )

    }

    func testFloatMaxValidation() {
        let key = Key<Float>("--key",
            description: "A key",
            validation: [.max(5.0)]
        )

        XCTAssertEqual(
            key.updateValue("7.0"),
            .validationError("Must be smaller then 5.0"),
            "Should validate max value and fail"
        )

        XCTAssertEqual(
            key.updateValue("2.0"),
            .succeeded,
            "Should validate max value and succeed"
        )

    }

    func testIntWithinValidation() {
        let key = Key<Int>("--key",
            description: "A key",
            validation: [.within(5...8)]
        )

        XCTAssertEqual(
            key.updateValue("3"),
            .validationError("Must be between 5 and 8"),
            "Should validate int outside (low) range and fail"
        )

        XCTAssertEqual(
            key.updateValue("9"),
            .validationError("Must be between 5 and 8"),
            "Should validate int outside (over) range and fail"
        )

        XCTAssertEqual(
            key.updateValue("5"),
            .succeeded,
            "Should succeed if at lower bound"
        )

        XCTAssertEqual(
            key.updateValue("8"),
            .succeeded,
            "Should succeed if at upper bound"
        )

        XCTAssertEqual(
            key.updateValue("7"),
            .succeeded,
            "Should validate in middle of range"
        )
    }

    func testFloatWithinValidation() {
        let key = Key<Float>("--key",
            description: "A key",
            validation: [.within(5.0...8.0)]
        )

        XCTAssertEqual(
            key.updateValue("3.0"),
            .validationError("Must be between 5.0 and 8.0"),
            "Should validate float outside (low) range and fail"
        )

        XCTAssertEqual(
            key.updateValue("9.0"),
            .validationError("Must be between 5.0 and 8.0"),
            "Should validate float outside (over) range and fail"
        )

        XCTAssertEqual(
            key.updateValue("5.0"),
            .succeeded,
            "Should succeed if at lower bound"
        )

        XCTAssertEqual(
            key.updateValue("8.0"),
            .succeeded,
            "Should succeed if at upper bound"
        )

        XCTAssertEqual(
            key.updateValue("7.0"),
            .succeeded,
            "Should validate in middle of range"
        )
    }
}
