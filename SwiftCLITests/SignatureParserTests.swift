//
//  SignatureParserTests.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Cocoa
import XCTest

class SignatureParserTests: XCTestCase {
    
    var signatureParser = SignatureParser(signature: "", arguments: [])
    var signature: String = ""
    var arguments: [String] = []
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testEmptySignature() {
        self.signature = ""
        
        self.arguments = []
        self.assertParserReturnsDictionary(NSDictionary.dictionary(), assertMessage: "An empty signature and arguments list should return an empty dictionary")
     
        self.arguments = ["arg1"]
        self.assertParserFails(assertMessage: "An empty signature and a non-zero arrray of arguments should fail")
    }
    
    func testRequiredArguments() {
        self.signature = "<req1>"
        
        self.arguments = []
        self.assertParserFails(assertMessage: "A signature with one required argument and an empty arguments array should fail")

        self.arguments = ["arg1"]
        self.assertParserReturnsDictionary(["req1": "arg1"], assertMessage: "A signature with one required argument and an arguments array of length one should return a valid dictionary")
        
        self.signature = "<req1> <req2>"
        
        self.arguments = ["arg1"]
        self.assertParserFails(assertMessage: "A signature with two required args and an arguments array of length two should fail")
        
        self.arguments = ["arg1", "arg2"]
        self.assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2"], assertMessage: "A signature with two required arguments and an arguments array of length two should return a valid dictionary")
    }
    
    func testOptionalArguments() {
        self.signature = "[<opt1>]"

        self.arguments = []
        self.assertParserReturnsDictionary(NSDictionary.dictionary(), assertMessage: "A signature with one optional argument and an empty arguments array should return an empty dictionary")
        
        self.arguments = ["arg1"]
        self.assertParserReturnsDictionary(["opt1": "arg1"], assertMessage: "A signature with one optional argument and an arguments array of length one should return a valid dictionary")
        
        self.signature = "[<opt1>] [<opt2>]"
        
        self.arguments = []
        self.assertParserReturnsDictionary(NSDictionary.dictionary(), assertMessage: "A signature with two optional arguments and an empty arguments array should return an empty dictionary")
        
        self.arguments = ["arg1"]
        self.assertParserReturnsDictionary(["opt1": "arg1"], assertMessage: "A signature with two optional arguments and an arguments array of length one should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2"]
        self.assertParserReturnsDictionary(["opt1": "arg1", "opt2": "arg2"], assertMessage: "A signature with two optional arguments and an arguments array of length one should return a valid dictionary")
    }
    
    func testSuperfluousArguments() {
        self.arguments = ["arg1", "arg2"]
        
        self.signature = "<req1>"
        self.assertParserFails(assertMessage: "A signature with one required argument and two given arguments should fail")
        
        self.signature = "<opt1>"
        self.assertParserFails(assertMessage: "A signature with one optional argument and two given arguments should fail")
    }
    
    func testLimitlessArgument() {
        self.signature = "<req1> ..."
       
        self.arguments = ["arg1"]
        self.assertParserReturnsDictionary(["req1": ["arg1"]], assertMessage: "A signature with one required argument and a limitless argument and one given argument should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2"]
        self.assertParserReturnsDictionary(["req1": ["arg1", "arg2"]], assertMessage: "A signature with one required argument and a limitless argument and two given arguments should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2", "arg3"]
        self.assertParserReturnsDictionary(["req1": ["arg1", "arg2", "arg3"]], assertMessage: "A signature with one required argument and a limitless argument and two given arguments should return a valid dictionary")
        
        
        self.signature = "[<opt1>] ..."
        
        self.arguments = ["arg1"]
        self.assertParserReturnsDictionary(["opt1": ["arg1"]], assertMessage: "A signature with one optional argument and a limitless argument and one given argument should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2"]
        self.assertParserReturnsDictionary(["opt1": ["arg1", "arg2"]], assertMessage: "A signature with one optional argument and a limitless argument and two given arguments should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2", "arg3"]
        self.assertParserReturnsDictionary(["opt1": ["arg1", "arg2", "arg3"]], assertMessage: "A signature with one optional argument and a limitless argument and three given arguments should return a valid dictionary")
        
        
        self.signature = "<req1> <req2> ..."

        self.arguments = ["arg1", "arg2"]
        self.assertParserReturnsDictionary(["req1": "arg1", "req2": ["arg2"]], assertMessage: "A signature with two required arguments and a limitless argument and two given arguments should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2", "arg3"]
        self.assertParserReturnsDictionary(["req1": "arg1", "req2": ["arg2", "arg3"]], assertMessage: "A signature with two required arguments and a limitless argument and three given arguments should return a valid dictionary")
        
        
        self.signature = "<opt1> <opt2> ..."
        
        self.arguments = ["arg1", "arg2"]
        self.assertParserReturnsDictionary(["opt1": "arg1", "opt2": ["arg2"]], assertMessage: "A signature with two optional arguments and a limitless argument and two given arguments should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2", "arg3"]
        self.assertParserReturnsDictionary(["opt1": "arg1", "opt2": ["arg2", "arg3"]], assertMessage: "A signature with two optional arguments and a limitless argument and three given arguments should return a valid dictionary")
    }
    
    func testCombinedRequiredAndOptional() {
        self.signature = "<req1> [<opt1>]"
        
        self.arguments = ["arg1"]
        self.assertParserReturnsDictionary(["req1": "arg1"], assertMessage: "A signature with a required argument and an optional argument and one given arguments should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2"]
        self.assertParserReturnsDictionary(["req1": "arg1", "opt1": "arg2"], assertMessage: "A signature with a required argument and an optional argument and two given arguments should return a valid dictionary")
        
        self.signature = "<req1> <req2> [<opt1>] [<opt2>]"
        
        self.arguments = ["arg1", "arg2", "arg3"]
        self.assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2", "opt1": "arg3"], assertMessage: "A signature with two required arguments and two optional arguments and three given arguments should return a valid dictionary")
        
        self.arguments = ["arg1", "arg2", "arg3", "arg4"]
        self.assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2", "opt1": "arg3", "opt2": "arg4"], assertMessage: "A signature with two required arguments and two optional arguments and four given arguments should return a valid dictionary")
    }
    
    func assertParserReturnsDictionary(returnDictionary: NSDictionary, assertMessage: String) {
        signatureParser = SignatureParser(signature: self.signature, arguments: self.arguments)
        let retVal = signatureParser.parse()
        XCTAssertEqual(retVal.keyedArguments!, returnDictionary, "\(assertMessage) -- \(retVal.keyedArguments) != \(returnDictionary)")
    }
    
    func assertParserFails(#assertMessage: String) {
        signatureParser = SignatureParser(signature: self.signature, arguments: self.arguments)
        let retVal = signatureParser.parse()
        XCTAssertNil(retVal.keyedArguments,  "\(assertMessage) -- \(retVal.keyedArguments) != nil")
    }
    
}
