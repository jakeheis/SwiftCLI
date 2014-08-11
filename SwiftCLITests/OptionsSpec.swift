//
//  OptionsSpec.swift
//  Example
//
//  Created by Jake Heiser on 8/10/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Cocoa
import Quick
import Nimble

class OptionsSpec: QuickSpec {

    override func spec() {
        
        describe("an options object") {
            
            var options = Options()
            
            beforeEach {
                options = Options()
            }
            
            describe("in its onOptions calls") {
                
                it("should expect flags after onFlag call") {
                    options.onFlags(["-f", "--force"], block: nil)
                    expect(options.expectedFlags).to(contain("-f"))
                    expect(options.expectedFlags).to(contain("--force"))
                }
                
                it("should expect keys after onKey call") {
                    options.onKeys(["-m", "--message"], block: nil)
                    expect(options.expectedKeys).to(contain("-m"))
                    expect(options.expectedKeys).to(contain("--message"))
                }
                
            }
            
            describe("in its creation of an unrecognized options methods") {
                
                var command = LightweightCommand(commandName: "")
                let routedName = "commit"
                
                beforeEach {
                    command = LightweightCommand(commandName: "commit")
                    command.printingBehaviorOnUnrecognizedOptions = .PrintNone
                }
                
                it("should return nil if the command has PrintNone behavior") {
                    let message = options.unaccountedForMessage(command: command, routedName: routedName)
                    expect(message).to(beNil())
                }
                
            }
            
        }
        
    }

}
