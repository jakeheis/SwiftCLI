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

    let testName = Argument()
    let testerName = OptionalArgument()
    
    let silent = Flag("-s", "--silent", usage: "Silence all test output")
    let times = Key<Int>("-t", "--times", usage: "Number of times to run the test")

    let completion: ((_ executionString: String) -> ())?

    init(completion: ((_ executionString: String) -> ())? = nil) {
        self.completion = completion
    }

    func execute() throws {
        executionString = "\(testerName.value!) will test \(testName.value), \(times.value ?? 1) times"
        if silent.value {
            executionString += ", silently"
        }

        completion?(executionString)
    }

}
