import XCTest
@testable import SwiftCLITests

XCTMain([
     testCase(CommandArgumentsTests.allTests),
     testCase(CommandMessageGeneratorTests.allTests),
     testCase(OptionsTests.allTests),
     testCase(RouterTests.allTests),
     testCase(SwiftCLITests.allTests)
])
