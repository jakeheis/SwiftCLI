//
//  SwiftCLITests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 6/28/16.
//  Copyright (c) 2016 jakeheis. All rights reserved.
//


import SwiftCLI

class TestCommand: OptionCommand {

    let name = "test"
    let shortDescription = "A command to test stuff"

    var silentFlag = false
    var times: Int = 1
    var executionString = ""

    let testName = Argument()
    let testerName = OptionalArgument()

    let completion: ((_ executionString: String) -> ())?

    init(completion: ((_ executionString: String) -> ())? = nil) {
        self.completion = completion
    }

    func setupOptions(options: OptionRegistry) {
        options.add(flags: ["-s", "--silent"], usage: "Silence all test output") {
            self.silentFlag = true
        }
        options.add(keys: ["-t", "--times"], usage: "Number of times to run the test", valueSignature: "times") { (value) in
            self.times = Int(value)!
        }
    }

    func execute() throws {
        executionString = "\(testerName.value!) will test \(testName.value), \(times) times"
        if silentFlag {
            executionString += ", silently"
        }

        completion?(executionString)
    }

}
