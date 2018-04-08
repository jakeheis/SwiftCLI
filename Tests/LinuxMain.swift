import XCTest
@testable import SwiftCLITests

XCTMain([
    testCase(ArgumentListManipulatorTests.allTests),
    testCase(ArgumentListTests.allTests),
    testCase(CompletionGeneratorTests.allTests),
    testCase(HelpMessageGeneratorTests.allTests),
    testCase(InputTests.allTests),
    testCase(OptionRegistryTests.allTests),
    testCase(ParserTests.allTests),
    testCase(StreamTests.allTests),
    testCase(SwiftCLITests.allTests),
    testCase(TaskTests.allTests)
])
