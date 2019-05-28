//
//  SwiftCLITests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//

import SwiftCLI
import XCTest

extension CLI {
    static func createTester(commands: [Routable], description: String? = nil) -> CLI {
        return CLI(name: "tester", description: description, commands: commands)
    }
}

class TestCommand: Command {

    let name = "test"
    let shortDescription = "A command to test stuff"

    var executionString = ""

    let testName = Parameter()
    let testerName = OptionalParameter()
    
    let silent = Flag("-s", "--silent", description: "Silence all test output")
    let times = Key<Int>("-t", "--times", description: "Number of times to run the test")

    let completion: ((_ executionString: String) -> ())?

    init(completion: ((_ executionString: String) -> ())? = nil) {
        self.completion = completion
    }

    func execute() throws {
        executionString = "\(testerName.value ?? "defaultTester") will test \(testName.value), \(times.value ?? 1) times"
        if silent.value {
            executionString += ", silently"
        }

        completion?(executionString)
    }

}

class TestCommandWithLongDescription: Command {

    let name = "test"
    let shortDescription = "A command to test stuff"
    let longDescription = "This is a long\nmultiline description"

    func execute() throws {
    }
}

class MultilineCommand: Command {

    let name = "test"
    let shortDescription = "A command that has multiline comments.\nNew line"

    let silent = Flag("-s", "--silent", description: "Silence all test output\nNewline")
    let times = Key<Int>("-t", "--times", description: "Number of times to run the test")

    func execute() throws {

    }

}

class TestInheritedCommand: TestCommand {
    let verbose = Flag("-v", "--verbose", description: "Show more output information")
}

// MARK: -

let alphaCmd = AlphaCmd()
let betaCmd = BetaCmd()
let charlieCmd = CharlieCmd()
let deltaCmd = DeltaCmd()

class AlphaCmd: Command {
    let name = "alpha"
    let shortDescription = "The alpha command"
    fileprivate init() {}
    func execute() throws {}
}

class BetaCmd: Command {
    let name = "beta"
    let shortDescription = "A beta command"
    fileprivate init() {}
    func execute() throws {}
}

class CharlieCmd: Command {
    let name = "charlie"
    let shortDescription = "A beta command"
    fileprivate init() {}
    func execute() throws {}
}

class DeltaCmd: Command {
    let name = "delta"
    let shortDescription = "A beta command"
    fileprivate init() {}
    func execute() throws {}
}

class EmptyCmd: Command {
    let name = "cmd"
    func execute() throws {}
}

class Req1Cmd: EmptyCmd {
    let req1 = Parameter(completion: .function("_ice_targets"))
}

class Opt1Cmd: EmptyCmd {
    let opt1 = OptionalParameter()
}

class Req2Cmd: EmptyCmd {
    let req1 = Parameter(completion: .filename)
    let req2 = Parameter(completion: .values([
        ("executable", "generates a project for a cli executable"),
        ("library", "generates project for a dynamic library"),
        ("other", "")
    ]))
}

class Opt2Cmd: EmptyCmd {
    let opt1 = OptionalParameter(completion: .filename)
    let opt2 = OptionalParameter(completion: .values([
        ("executable", "generates a project for a cli executable"),
        ("library", "generates project for a dynamic library")
    ]))
}

class Opt2InhCmd: Opt2Cmd {
    let opt3 = OptionalParameter()
}

class ReqCollectedCmd: EmptyCmd {
    let req1 = CollectedParameter()
}

class OptCollectedCmd: EmptyCmd {
    let opt1 = OptionalCollectedParameter()
}

class Req2CollectedCmd: EmptyCmd {
    let req1 = Parameter(completion: .values([
        ("executable", "generates a project for a cli executable"),
        ("library", "generates project for a dynamic library")
        ]))
    let req2 = CollectedParameter(completion: .filename)
}

class Opt2CollectedCmd: EmptyCmd {
    let opt1 = OptionalParameter()
    let opt2 = OptionalCollectedParameter()
}

class Req2Opt2Cmd: EmptyCmd {
    let req1 = Parameter(completion: .filename)
    let req2 = Parameter(completion: .function("_swift_dependency"))
    let opt1 = OptionalParameter(completion: .none)
    let opt2 = OptionalParameter(completion: .filename)
}

// MARK: -

let midGroup = MidGroup()
let intraGroup = IntraGroup()

class MidGroup: CommandGroup {
    let name = "mid"
    let shortDescription = "The mid level of commands"
    let children: [Routable] = [alphaCmd, betaCmd]
    fileprivate init() {}
}

class IntraGroup: CommandGroup {
    let name = "intra"
    let shortDescription = "The intra level of commands"
    let children: [Routable] = [charlieCmd, deltaCmd]
    fileprivate init() {}
}

// MARK: -

class OptionCmd: Command {
    let name = "cmd"
    let shortDescription = ""
    func execute() throws {}
}

class FlagCmd: OptionCmd {
    let flag = Flag("-a", "--alpha")
}

class ReverseFlagCmd: OptionCmd {
    let flag = Flag("-r", "--reverse", defaultValue: true)
}

class KeyCmd: OptionCmd {
    let key = Key<String>("-a", "--alpha")
}

class DoubleFlagCmd: OptionCmd {
    let alpha = Flag("-a", "--alpha", description: "The alpha flag")
    let beta = Flag("-b", "--beta", description: "The beta flag")
}

class DoubleKeyCmd: OptionCmd {
    let alpha = Key<String>("-a", "--alpha")
    let beta = Key<String>("-b", "--beta")
}

class FlagKeyCmd: OptionCmd {
    let alpha = Flag("-a", "--alpha")
    let beta = Key<String>("-b", "--beta")
}

class FlagKeyParamCmd: OptionCmd {
    let alpha = Flag("-a", "--alpha")
    let beta = Key<String>("-b", "--beta")
    let param = Parameter()
}

class IntKeyCmd: OptionCmd {
    let alpha = Key<Int>("-a", "--alpha")
}

class ExactlyOneCmd: Command {
    let name = "cmd"
    let shortDescription = ""
    var helpFlag: Flag? = nil
    func execute() throws {}
    
    let alpha = Flag("-a", "--alpha", description: "the alpha flag")
    let beta = Flag("-b", "--beta", description: "the beta flag")
    
    let optionGroups: [OptionGroup]
    
    init() {
        optionGroups = [.exactlyOne(alpha, beta)]
    }
    
}

class MultipleRestrictionsCmd: Command {
    let name = "cmd"
    
    let alpha = Flag("-a", "--alpha", description: "the alpha flag")
    let beta = Flag("-b", "--beta", description: "the beta flag")
    
    lazy var atMostOne: OptionGroup = .atMostOne(alpha, beta)
    lazy var atMostOneAgain: OptionGroup = .atMostOne(alpha, beta)
    
    var optionGroups: [OptionGroup] {
        return [atMostOne, atMostOneAgain]
    }
    
    func execute() throws {}
}

class VariadicKeyCmd: OptionCmd {
    let files = VariadicKey<String>("-f", "--file", description: "a file")
}

class CounterFlagCmd: OptionCmd {
    let verbosity = CounterFlag("-v", "--verbose", description: "Increase the verbosity")
}

class ValidatedKeyCmd: OptionCmd {
    
    static func isCapitalized(_ value: String) -> Bool {
        return value.capitalized == value
    }
    
    let firstName = Key<String>("-n", "--name", validation: [
        .custom("Must be a capitalized first name", isCapitalized)
    ])
    
    let age = Key<Int>("-a", "--age", validation: [.greaterThan(18)])
    
    let location = Key<String>("-l", "--location", validation: [.rejecting("Chicago", "Boston")])
    
    let holiday = Key<String>("--holiday", validation: [.allowing("Thanksgiving", "Halloween")])
    
}

class QuoteDesciptionCmd: Command {
    let name = "cmd"
    let shortDescription = "this description has a \"quoted section\""
    
    let flag = Flag("-q", "--quoted", description: "also has \"quotes\"")
    
    func execute() throws {}
}

class CompletionOptionCmd: OptionCmd {
    let values = Key<String>("-v", "--values", completion: .values([("opt1", "first option"), ("opt2", "second option")]))
    let function = Key<String>("-f", "--function", completion: .function("_a_func"))
    let filename = Key<String>("-n", "--name", completion: .filename)
    let none = Key<String>("-z", "--zero", completion: .none)
    let def = Key<String>("-d", "--default")
    
    let flag = Flag("-f", "--flag")
}

class EnumCmd: Command {
    
    enum Speed: String, ConvertibleFromString {
        case slow
        case fast
    }
    
    enum Single: String, ConvertibleFromString {
        case value
        
        static let explanationForConversionFailure = "only can be 'value'"
    }
    
    let name = "cmd"
    let shortDescription = "Limits param values to enum"
    
    let speed = Param.Required<Speed>()
    let single = Param.Optional<Single>()
    let int = Param.Optional<Int>()
    
    func execute() throws {}
    
}

#if swift(>=4.1.50)
extension EnumCmd.Speed: CaseIterable {}
#endif

class ValidatedParamCmd: Command {
    
    let name = "cmd"
    let shortDescription = "Validates param values"
    
    let age = Param.Optional<Int>(validation: [.greaterThan(18)])
    
    func execute() throws {}
    
}

class RememberExecutionCmd: Command {
    
    let name = "cmd"
    let shortDescription = "Remembers execution"
    
    let param = OptionalParameter()
    
    var executed = false
    
    func execute() throws {
        executed = true
    }
    
}

// MARK: -

func XCTAssertThrowsSpecificError<T, E: Error>(
    expression: @autoclosure () throws -> T,
    file: StaticString = #file,
    line: UInt = #line,
    error errorHandler: (E) -> Void) {
    XCTAssertThrowsError(expression, file: file, line: line) { (error) in
        guard let specificError = error as? E else {
            XCTFail("Error must be type \(String(describing: E.self)), is \(String(describing: type(of: error)))", file: file, line: line)
            return
        }
        errorHandler(specificError)
    }
}

func XCTAssertEqualLineByLine(_ s1: String, _ s2: String, file: StaticString = #file, line: UInt = #line) {
    let lines1 = s1.components(separatedBy: "\n")
    let lines2 = s2.components(separatedBy: "\n")
    
    XCTAssertEqual(lines1.count, lines2.count, "line count should be equal", file: file, line: line)
    
    for (l1, l2) in zip(lines1, lines2) {
        XCTAssertEqual(l1, l2, file: file, line: line)
    }
}

extension CLI {
    
    static func capture(_ block: () -> ()) -> (String, String) {
        let out = CaptureStream()
        let err = CaptureStream()
        
        Term.stdout = out
        Term.stderr = err
        block()
        Term.stdout = WriteStream.stdout
        Term.stderr = WriteStream.stderr
        
        out.closeWrite()
        err.closeWrite()
        
        return (out.readAll(), err.readAll())
    }
    
}
