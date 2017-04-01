import XCTest
@testable import SwiftCLITests

XCTMain([
	 testCase(ArgumentListManipulatorTests.allTests),
	 testCase(ArgumentListTests.allTests),
	 testCase(CommandMessageGeneratorTests.allTests),
	 testCase(OptionRecognizerTests.allTests),
     testCase(OptionRegistryTests.allTests),
	 testCase(ParameterFillerTests.allTests),
     testCase(RouterTests.allTests),
     testCase(SwiftCLITests.allTests)
])
