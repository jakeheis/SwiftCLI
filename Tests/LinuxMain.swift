import XCTest
@testable import SwiftCLITests

XCTMain([
     testCase(CommandArgumentTests.allTests),
     testCase(CommandMessageGeneratorTests.allTests),
     testCase(OptionsTests.allTests),
     testCase(RouterTests.allTests),
     testCase(SwiftCLITests.allTests)
])
