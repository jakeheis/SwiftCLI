import XCTest
@testable import SwiftCLI

enum Car: String, Validatable, ConvertibleFromString {
    case volvo, volkswagen, bmw, ferrari

    public enum ValidationOption: Validatorable {
        case isFast

        public func validate(element: Car) -> ValidationResult {
            switch (self, element) {
            case (.isFast, .ferrari):
                return .succeeded
            default:
                return .failed("Is not fast")
            }
        }
    }
}

class ValidationEnumTests: XCTestCase {
    static var allTests : [(String, (ValidationEnumTests) -> () -> Void)] {
        return [
            ("testEnumValidation", testEnumValidation)
        ]
    }

    func testEnumValidation() {
        let car = Key<Car>("--car",
          description: "A car",
          validation: [.isFast]
        )

        XCTAssertEqual(
            car.updateValue("volvo"),
            .validationError("Is not fast"),
            "Should fail on slow car"
        )

        XCTAssertEqual(
            car.updateValue("ferrari"),
            .succeeded,
            "Should succeed on fast car"
        )
    }
}
