//
//  RouterTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 1/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

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
        let args = ArgumentList(argumentString: "tester")
        
        let command = route(args)
        XCTAssert(command == nil)
    }
    
    func testNameRoute() {
        let args = ArgumentList(argumentString: "tester alpha")
        
        guard let command = route(args) else {
            XCTFail()
            return
        }
        XCTAssertEqual(command.name, alphaCommand.name, "Router should route to the command with the given name")
        XCTAssert(args.head == nil, "Router should leave no arguments for the command")
    }
    
    // [baker, bake, cake, -qt, frosting]
    // Node(bake) -> Node(cake) -> Node(-qt) -> Node(frosting)
    // ArgumentListManipulators()
    // Node(bake) -> Node(cake) -> Node(-q) -> Node(-t) -> Node(frosting)
    // Router()
    // Command: bake -- Node(cake) -> Node(--with-topping) -> Node(frosting)
    // OptionRecognizer()
    // Command: bake, Options: topped with frosting -- Node(cake)
    // CommandArgumentParser()
    // Command: bake, Arguments: cake, Options: topped with frosting
    
    func testAliasRoute() {
        let args = ArgumentList(argumentString: "tester -b")
        
        let aliaser = CommandAliaser()
        aliaser.alias(from: "-b", to: "beta")
        aliaser.manipulate(arguments: args)
        
        guard let command = route(args) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(command.name, betaCommand.name, "Router with enabled shortcut routing should route to the command with the given shortcut")
        
        XCTAssert(args.head == nil, "Enabled router should pass on no arguments to the matched command")
    }
    
    func testFallbackCommandFlag() {
        let args = ArgumentList(argumentString: "tester -a")
        
        guard let command = route(args, router: DefaultRouter(fallbackCommand: fallbackCommand)) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(command.name, fallbackCommand.name, "Router should route to the fallback command when the flag does not match any command shortcut")
        XCTAssert(args.head?.value == "-a" && args.head?.next == nil, "Router should pass the flag on to the fallback command")
    }
    
    func testFailedRoute() {
        let args = ArgumentList(argumentString: "tester charlie")
        
        let command = route(args)
        XCTAssert(command == nil)
    }
    
    // MARK: - Helper
    
    private func route(_ arguments: ArgumentList, router: Router? = nil) -> Command? {
        let commands = [alphaCommand, betaCommand, fallbackCommand] as [Command]
        
        let router = router ?? DefaultRouter()
        return router.route(commands: commands, arguments: arguments)
    }
    
}
