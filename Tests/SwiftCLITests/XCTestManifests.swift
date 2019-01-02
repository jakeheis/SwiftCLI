import XCTest

extension ArgumentListManipulatorTests {
    static let __allTests = [
        ("testEqualsSplit", testEqualsSplit),
        ("testOptionSplitter", testOptionSplitter),
    ]
}

extension ArgumentListTests {
    static let __allTests = [
        ("testManipulate", testManipulate),
        ("testStringParse", testStringParse),
    ]
}

extension CompletionGeneratorTests {
    static let __allTests = [
        ("testBasicOptions", testBasicOptions),
        ("testEscaping", testEscaping),
        ("testFunction", testFunction),
        ("testGroup", testGroup),
        ("testLayered", testLayered),
        ("testOptionCompletion", testOptionCompletion),
        ("testParameterCompletion", testParameterCompletion),
        ("testSepcialCaseOptionCompletion", testSepcialCaseOptionCompletion),
    ]
}

extension HelpMessageGeneratorTests {
    static let __allTests = [
        ("testCommandListGeneration", testCommandListGeneration),
        ("testCommandNotFound", testCommandNotFound),
        ("testCommandNotSpecified", testCommandNotSpecified),
        ("testExpectedValueAfterKey", testExpectedValueAfterKey),
        ("testIllegalOptionType", testIllegalOptionType),
        ("testInheritedUsageStatementGeneration", testInheritedUsageStatementGeneration),
        ("testLongDescriptionGeneration", testLongDescriptionGeneration),
        ("testMisusedOptionsStatementGeneration", testMisusedOptionsStatementGeneration),
        ("testMutlineCommandListGeneration", testMutlineCommandListGeneration),
        ("testMutlineUsageStatementGeneration", testMutlineUsageStatementGeneration),
        ("testNoCommandMisusedOption", testNoCommandMisusedOption),
        ("testOptionGroupMisuse", testOptionGroupMisuse),
        ("testParameterCountError", testParameterCountError),
        ("testParameterTypeError", testParameterTypeError),
        ("testUsageStatementGeneration", testUsageStatementGeneration),
    ]
}

extension InputTests {
    static let __allTests = [
        ("testBool", testBool),
        ("testDouble", testDouble),
        ("testInt", testInt),
        ("testValidation", testValidation),
    ]
}

extension OptionRegistryTests {
    static let __allTests = [
        ("testFlagDetection", testFlagDetection),
        ("testKeyDetection", testKeyDetection),
        ("testMultipleRestrictions", testMultipleRestrictions),
        ("testVariadicDetection", testVariadicDetection),
    ]
}

extension ParameterFillerTests {
    static let __allTests = [
        ("testCollectedOptionalParameters", testCollectedOptionalParameters),
        ("testCollectedRequiredParameters", testCollectedRequiredParameters),
        ("testCombinedRequiredAndOptionalParameters", testCombinedRequiredAndOptionalParameters),
        ("testCustomParameter", testCustomParameter),
        ("testEmptyOptionalCollectedParameter", testEmptyOptionalCollectedParameter),
        ("testEmptySignature", testEmptySignature),
        ("testOptionalParameters", testOptionalParameters),
        ("testOptionalParametersWithInheritance", testOptionalParametersWithInheritance),
        ("testRequiredParameters", testRequiredParameters),
    ]
}

extension ParserTests {
    static let __allTests = [
        ("testBeforeCommand", testBeforeCommand),
        ("testCollectedOptions", testCollectedOptions),
        ("testCombinedFlagsAndKeysAndArgumentsParsing", testCombinedFlagsAndKeysAndArgumentsParsing),
        ("testCombinedFlagsAndKeysParsing", testCombinedFlagsAndKeysParsing),
        ("testDefaultFlagValue", testDefaultFlagValue),
        ("testFlagSplitting", testFlagSplitting),
        ("testFullParse", testFullParse),
        ("testGroupRestriction", testGroupRestriction),
        ("testIllegalOptionFormat", testIllegalOptionFormat),
        ("testKeysNotGivenValues", testKeysNotGivenValues),
        ("testKeyValueParsing", testKeyValueParsing),
        ("testSimpleFlagParsing", testSimpleFlagParsing),
        ("testSimpleKeyParsing", testSimpleKeyParsing),
        ("testUnrecognizedOptions", testUnrecognizedOptions),
        ("testValidation", testValidation),
        ("testVaridadicParse", testVaridadicParse),
    ]
}

extension RouterTests {
    static let __allTests = [
        ("testAliasRoute", testAliasRoute),
        ("testFailedRoute", testFailedRoute),
        ("testGroupFailedRoute", testGroupFailedRoute),
        ("testGroupPartialRoute", testGroupPartialRoute),
        ("testGroupSuccessRoute", testGroupSuccessRoute),
        ("testNameRoute", testNameRoute),
        ("testNestedGroup", testNestedGroup),
        ("testSingleRouter", testSingleRouter),
    ]
}

extension StreamTests {
    static let __allTests = [
        ("testCaptureStream", testCaptureStream),
        ("testLineStream", testLineStream),
        ("testNullStream", testNullStream),
        ("testRead", testRead),
        ("testReadAll", testReadAll),
        ("testReadData", testReadData),
        ("testReadFile", testReadFile),
        ("testReadLine", testReadLine),
        ("testReadLines", testReadLines),
        ("testWrite", testWrite),
        ("testWriteData", testWriteData),
        ("testWriteFile", testWriteFile),
    ]
}

extension SwiftCLITests {
    static let __allTests = [
        ("testCLIHelp", testCLIHelp),
        ("testCommandHelp", testCommandHelp),
        ("testGlobalOptions", testGlobalOptions),
        ("testGoWithArguments", testGoWithArguments),
        ("testOptionSplit", testOptionSplit),
        ("testSingleCommand", testSingleCommand),
    ]
}

extension TaskTests {
    static let __allTests = [
        ("testBashCapture", testBashCapture),
        ("testBashRun", testBashRun),
        ("testCapture", testCapture),
        ("testCaptureDirectory", testCaptureDirectory),
        ("testCurrentDirectory", testCurrentDirectory),
        ("testEnv", testEnv),
        ("testExecutableFind", testExecutableFind),
        ("testIn", testIn),
        ("testPipe", testPipe),
        ("testRun", testRun),
        ("testRunDirectory", testRunDirectory),
        ("testSignals", testSignals),
        ("testTaskLineStream", testTaskLineStream),
        ("testTaskNullStream", testTaskNullStream),
    ]
}

extension ValidationTests {
    static let __allTests = [
        ("testComparable", testComparable),
        ("testEquatable", testEquatable),
        ("testString", testString),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ArgumentListManipulatorTests.__allTests),
        testCase(ArgumentListTests.__allTests),
        testCase(CompletionGeneratorTests.__allTests),
        testCase(HelpMessageGeneratorTests.__allTests),
        testCase(InputTests.__allTests),
        testCase(OptionRegistryTests.__allTests),
        testCase(ParameterFillerTests.__allTests),
        testCase(ParserTests.__allTests),
        testCase(RouterTests.__allTests),
        testCase(StreamTests.__allTests),
        testCase(SwiftCLITests.__allTests),
        testCase(TaskTests.__allTests),
        testCase(ValidationTests.__allTests),
    ]
}
#endif
