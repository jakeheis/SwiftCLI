//
//  SwiftCLITests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//


import SwiftCLI

class TestCommand: Command {

    let name = "test"
    let shortDescription = "A command to test stuff"
    
    var executionString = ""

    let testName = Parameter()
    let testerName = OptionalParameter()
    
    let silent = Flag("-s", "--silent", usage: "Silence all test output")
    let times = Key<Int>("-t", "--times", usage: "Number of times to run the test")

    let completion: ((_ executionString: String) -> ())?

    init(completion: ((_ executionString: String) -> ())? = nil) {
        self.completion = completion
    }

    func execute() throws {
        executionString = "\(testerName.value ?? "defaultTester") will test \(testName.value), \(times.value ?? 1) times"
        if silent.value {
            executionString += ", silently"
        }
        if verbose.value {
            executionString += ", verbosely"
        }

        completion?(executionString)
    }

}

// MARK: -

class EmptyCmd: Command {
    let name = "req"
    let shortDescription = ""
    func execute() throws {}
}

class Req1Cmd: EmptyCmd {
    let req1 = Parameter()
}

class Opt1Cmd: EmptyCmd {
    let opt1 = OptionalParameter()
}

class Req2Cmd: EmptyCmd {
    let req1 = Parameter()
    let req2 = Parameter()
}

class Opt2Cmd: EmptyCmd {
    let opt1 = OptionalParameter()
    let opt2 = OptionalParameter()
}

class ReqCollectedCmd: EmptyCmd {
    let req1 = CollectedParameter()
}

class OptCollectedCmd: EmptyCmd {
    let opt1 = OptionalCollectedParameter()
}

class Req2CollectedCmd: EmptyCmd {
    let req1 = Parameter()
    let req2 = CollectedParameter()
}

class Opt2CollectedCmd: EmptyCmd {
    let opt1 = OptionalParameter()
    let opt2 = OptionalCollectedParameter()
}

class Req2Opt2Cmd: EmptyCmd {
    let req1 = Parameter()
    let req2 = Parameter()
    let opt1 = OptionalParameter()
    let opt2 = OptionalParameter()
}

// MARK: -

class OptionCmd: Command {
    let name = "cmd"
    let shortDescription = ""
    var helpFlag: Flag? = nil
    func execute() throws {}
}

class FlagCmd: OptionCmd {
    let flag = Flag("-a", "--alpha")
}

class KeyCmd: OptionCmd {
    let key = Key<String>("-a", "--alpha")
}

class DoubleFlagCmd: OptionCmd {
    let alpha = Flag("-a", "--alpha")
    let beta = Flag("-b", "--beta")
}

class DoubleKeyCmd: OptionCmd {
    let alpha = Key<String>("-a", "--alpha")
    let beta = Key<String>("-b", "--beta")
}

class FlagKeyCmd: OptionCmd {
    let alpha = Flag("-a", "--alpha")
    let beta = Key<String>("-b", "--beta")
}

class IntKeyCmd: OptionCmd {
    let alpha = Key<Int>("-a", "--alpha")
}

class ExactlyOneCmd: Command {
    let name = "cmd"
    let shortDescription = ""
    var helpFlag: Flag? = nil
    func execute() throws {}
    
    let alpha = Flag("-a", "--alpha")
    let beta = Flag("-b", "--beta")
    
    let optionGroups: [OptionGroup]
    
    init() {
        optionGroups = [OptionGroup(options: [alpha, beta], restriction: .exactlyOne)]
    }
    
}
