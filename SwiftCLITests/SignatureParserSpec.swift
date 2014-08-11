//
//  SignatureParserTests.swift
//  Example
//
//  Created by Jake Heiser on 8/2/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Cocoa
import Quick
import Nimble

class SignatureParserSpec: QuickSpec {
    
    var signature: String = ""
    var arguments: [String] = []
    
    override func spec() {
        
        describe("the signature parser") {
        
            context("when given an empty signature") {
                
                beforeEach {
                    self.signature = ""
                }
                
                it("returns an empty signature given no arguments") {
                    self.arguments = []
                    self.assertParserReturnsDictionary(NSDictionary.dictionary())
                }
                
                it("fails given any arguments") {
                    self.arguments = ["arg1"]
                    self.assertParserFails()
                }
            }
            
            context("when the signature has required arguments") {
                
                context("with one required argument") {
                    
                    beforeEach {
                        self.signature = "<req1>"
                    }
                    
                    it("only passes when given one argument") {
                        self.arguments = []
                        self.assertParserFails()
                        
                        self.arguments = ["arg1"]
                        self.assertParserReturnsDictionary(["req1": "arg1"])
                    }
                    
                }

                context("with two required arguments") {
                    
                    beforeEach {
                        self.signature = "<req1> <req2>"
                    }
                    
                    it("only passes when given two arguments") {
                        self.arguments = ["arg1"]
                        self.assertParserFails()
                        
                        self.arguments = ["arg1", "arg2"]
                        self.assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2"])
                    }
                    
                }
                
            }
            
            context("when the signature has optional arguments") {
                
                context("with one optional argument") {
                    
                    beforeEach {
                        self.signature = "[<opt1>]"
                    }
                    
                    it("passes with one or zero arguments") {
                        self.arguments = []
                        self.assertParserReturnsDictionary(NSDictionary.dictionary())
                        
                        self.arguments = ["arg1"]
                        self.assertParserReturnsDictionary(["opt1": "arg1"])
                    }
                    
                }
                
                context("with two optional arguments") {
                    
                    beforeEach {
                        self.signature = "[<opt1>] [<opt2>]"
                    }
                    
                    it("passes with 0-2 arguments") {
                        self.arguments = []
                        self.assertParserReturnsDictionary(NSDictionary.dictionary())
                        
                        self.arguments = ["arg1"]
                        self.assertParserReturnsDictionary(["opt1": "arg1"])
                        
                        self.arguments = ["arg1", "arg2"]
                        self.assertParserReturnsDictionary(["opt1": "arg1", "opt2": "arg2"])
                    }
                    
                }
                
            }

            context("when extra arguments are passed") {
                
                beforeEach {
                    self.arguments = ["arg1", "arg2"]
                }
                
                it("should fail with only one required argument") {
                    self.signature = "<req1>"
                    self.assertParserFails()
                }
                
                it("should fail with only one optional argument") {
                    self.signature = "[<opt1>]"
                    self.assertParserFails()
                }
                
            }
            
            context("when the signature contains a non-terminal argument") {
                
                context("with one required argument") {
                    
                    beforeEach {
                        self.signature = "<req1> ..."
                    }
                    
                    it("should pass with one or more arguments") {
                        self.arguments = ["arg1"]
                        self.assertParserReturnsDictionary(["req1": ["arg1"]])
                        
                        self.arguments = ["arg1", "arg2"]
                        self.assertParserReturnsDictionary(["req1": ["arg1", "arg2"]])
                        
                        self.arguments = ["arg1", "arg2", "arg3"]
                        self.assertParserReturnsDictionary(["req1": ["arg1", "arg2", "arg3"]])
                    }
                    
                }
                
                context("with one optional argument") {
                    
                    beforeEach {
                        self.signature = "[<opt1>] ..."
                    }
                    
                    it("should pass with one or more arguments") {
                        self.arguments = ["arg1"]
                        self.assertParserReturnsDictionary(["opt1": ["arg1"]])
                        
                        self.arguments = ["arg1", "arg2"]
                        self.assertParserReturnsDictionary(["opt1": ["arg1", "arg2"]])
                        
                        self.arguments = ["arg1", "arg2", "arg3"]
                        self.assertParserReturnsDictionary(["opt1": ["arg1", "arg2", "arg3"]])
                    }
                    
                }
                
                context("with two required arguments") {
                    
                    beforeEach {
                        self.signature = "<req1> <req2> ..."
                    }
                    
                    it("should pass with two or more arguments") {
                        self.arguments = ["arg1", "arg2"]
                        self.assertParserReturnsDictionary(["req1": "arg1", "req2": ["arg2"]])
                        
                        self.arguments = ["arg1", "arg2", "arg3"]
                        self.assertParserReturnsDictionary(["req1": "arg1", "req2": ["arg2", "arg3"]])
                    }
                    
                }
                
                context("with two optional arguments") {
                    
                    beforeEach {
                        self.signature = "[<opt1>] [<opt2>] ..."
                    }
                    
                    it("should pass with two or more arguments") {
                        self.arguments = ["arg1", "arg2"]
                        self.assertParserReturnsDictionary(["opt1": "arg1", "opt2": ["arg2"]])
                        
                        self.arguments = ["arg1", "arg2", "arg3"]
                        self.assertParserReturnsDictionary(["opt1": "arg1", "opt2": ["arg2", "arg3"]])
                    }
                    
                }
                
                it("should only pass if placed at the end of the signature") {
                    self.arguments = ["arg1", "arg2", "arg3"]
                    
                    self.signature = "<req1> ... <req2>"
//                    self.assertParserFails(assertMessage: "A signature with the nonterminal argument not at the end should fail")
                    self.signature = "<req1> <req2> ..."
                    self.assertParserReturnsDictionary(["req1": "arg1", "req2": ["arg2", "arg3"]])
                }
                
            }
            
            context("when required and optional arguments are combined") {
                
                context("with one required and one optional argument") {
                    
                    beforeEach {
                        self.signature = "<req1> [<opt1>]"
                    }
                    
                    it("should pass with one or two arguments") {
                        self.arguments = ["arg1"]
                        self.assertParserReturnsDictionary(["req1": "arg1"])
                        
                        self.arguments = ["arg1", "arg2"]
                        self.assertParserReturnsDictionary(["req1": "arg1", "opt1": "arg2"])
                    }
                    
                }
                
                context("with two required and two optional arguments") {
                    
                    beforeEach {
                        self.signature = "<req1> <req2> [<opt1>] [<opt2>]"
                    }
                    
                    it("should pass with three or four arguments") {
                        self.arguments = ["arg1", "arg2", "arg3"]
                        self.assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2", "opt1": "arg3"])
                        
                        self.arguments = ["arg1", "arg2", "arg3", "arg4"]
                        self.assertParserReturnsDictionary(["req1": "arg1", "req2": "arg2", "opt1": "arg3", "opt2": "arg4"])
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func assertParserReturnsDictionary(returnDictionary: NSDictionary) {
        let signatureParser = SignatureParser(signature: self.signature, arguments: self.arguments)
        let retVal = signatureParser.parse()
        expect(retVal.keyedArguments!).to(equal(returnDictionary));
    }
    
    func assertParserFails() {
        let signatureParser = SignatureParser(signature: self.signature, arguments: self.arguments)
        let retVal = signatureParser.parse()
        expect(retVal.keyedArguments).to(beNil())
    }
    
}
