//
//  RouterTests.swift
//  Example
//
//  Created by Jake Heiser on 1/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCLI

class RouterTests: XCTestCase {
    
    static var allTests : [(String, (RouterTests) -> () throws -> Void)] {
        return [
            ("testNoRoute", testNoRoute),
            ("testNameRoute", testNameRoute),
            ("testAliasRoute", testAliasRoute),
            ("testFallbackCommandFlag", testFallbackCommandFlag),
            ("testFailedRoute", testFailedRoute)
        ]
    }
    
    var alphaCommand: Command!
    var betaCommand: Command!
    var fallbackCommand: Command!
    
    override func setUp() {
        super.setUp()
        
        alphaCommand = LightweightCommand(name: "alpha")
        betaCommand = ChainableCommand(name: "beta")
        fallbackCommand = LightweightCommand(name: "fallback")
    }
    
    // MARK: - Tests
    
    func testNoRoute() {
        let args = RawArguments(argumentString: "tester")
        
        let command = route(args)
        XCTAssert(command == nil)
    }
    
    func testNameRoute() {
        let args = RawArguments(argumentString: "tester alpha")
        
        guard let command = route(args) else {
            XCTFail()
            return
        }
        XCTAssertEqual(command.name, alphaCommand.name, "Router should route to the command with the given name")
        XCTAssert(args.unclassifiedArguments.isEmpty, "Router should leave no arguments for the command")
    }
    
    func testAliasRoute() {
        let args = RawArguments(argumentString: "tester -b")
        
        guard let command = route(args) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(command.name, betaCommand.name, "Router with enabled shortcut routing should route to the command with the given shortcut")
        
        XCTAssert(args.unclassifiedArguments.isEmpty, "Enabled router should pass on no arguments to the matched command")
    }
    
    func testFallbackCommandFlag() {
        let args = RawArguments(argumentString: "tester -a")
        
        guard let command = route(args, router: DefaultRouter(fallbackCommand: fallbackCommand)) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(command.name, fallbackCommand.name, "Router should route to the fallback command when the flag does not match any command shortcut")
        XCTAssertEqual(args.unclassifiedArguments.map { $0.value }, ["-a"], "Router should pass the flag on to the fallback command")
    }
    
    func testFailedRoute() {
        let args = RawArguments(argumentString: "tester charlie")
        
        let command = route(args)
        XCTAssert(command == nil)
    }
    
    // MARK: - Helper
    
    private func route(_ arguments: RawArguments, router: Router? = nil) -> Command? {
        let commands = [alphaCommand, betaCommand, fallbackCommand] as [Command]
        
        let aliases = [
            "-b": "beta"
        ]
        let router = router ?? DefaultRouter()
        return router.route(commands: commands, aliases: aliases, arguments: arguments)
    }
    
}
