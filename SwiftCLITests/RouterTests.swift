//
//  RouterTests.swift
//  Example
//
//  Created by Jake Heiser on 1/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Cocoa
import XCTest

class RouterTests: XCTestCase {
    
    var defaultCommand: Command!
    var alphaCommand: Command!
    var betaCommand: Command!
    
    override func setUp() {
        super.setUp()
        
        alphaCommand = LightweightCommand(commandName: "alpha")
        betaCommand = ChainableCommand(commandName: "beta").withShortcut("-b")
        defaultCommand = LightweightCommand(commandName: "default")
    }
    
    // MARK: - Tests
    
    func testDefaultRoute() {
        let args = RawArguments(argumentString: "tester")
        let router = createRouter(arguments: args)
        
        if let route = router.route().value {
            XCTAssertEqual(route.command, defaultCommand, "Router should route to the default command if no arguments are given")
            XCTAssert(route.arguments.unclassifiedArguments().count == 0, "Router should leave no arguments for the command")
        } else {
            XCTFail("Router should not fail when a default command exists")
        }
    }
    
    func testNameRoute() {
        let args = RawArguments(argumentString: "tester alpha")
        let router = createRouter(arguments: args)
        if let route = router.route().value {
            XCTAssertEqual(route.command, alphaCommand, "Router should route to the command with the given name")
            XCTAssert(route.arguments.unclassifiedArguments().count == 0, "Router should leave no arguments for the command")
        } else {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    func testShortcutRoute() {
        let args = RawArguments(argumentString: "tester -b")
        let router = createRouter(arguments: args)
        if let route = router.route().value {
            XCTAssertEqual(route.command, betaCommand, "Router should route to the command with the given shortcut")
            XCTAssert(route.arguments.unclassifiedArguments().count == 0, "Router should leave no arguments for the command")
        } else {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    func testDefaultCommandFlag() {
        let args = RawArguments(argumentString: "tester -a")
        let router = createRouter(arguments: args)
        if let route = router.route().value {
            XCTAssertEqual(route.command, defaultCommand, "Router should route to the default command when the flag does not match any command shortcut")
            XCTAssertEqual(route.arguments.unclassifiedArguments(), ["-a"], "Router should pass the flag on to the default command")
        } else {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    func testFailedRoute() {
        let args = RawArguments(argumentString: "tester charlie")
        let router = createRouter(arguments: args)
        if router.route().isSuccess {
            XCTFail("Router should fail when the command does not exist")
        }
    }
    
    // MARK: - Helper
    
    private func createRouter(#arguments: RawArguments) -> Router {
        let commands = [alphaCommand, betaCommand, defaultCommand] as [Command]
        return Router(commands: commands, arguments: arguments, defaultCommand: defaultCommand)
    }
    
}
