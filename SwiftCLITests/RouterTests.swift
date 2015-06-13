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
    
    var defaultCommand: CommandType!
    var alphaCommand: CommandType!
    var betaCommand: CommandType!
    
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
        
        do {
            let command = try router.route()
            XCTAssertEqual(command.commandName, defaultCommand.commandName, "Router should route to the default command if no arguments are given")
            XCTAssert(args.unclassifiedArguments().count == 0, "Router should leave no arguments for the command")
        } catch {
             XCTFail("Router should not fail when a default command exists")
        }
    }
    
    func testNameRoute() {
        let args = RawArguments(argumentString: "tester alpha")
        let router = createRouter(arguments: args)
        
        do {
            let command = try router.route()
            XCTAssertEqual(command.commandName, alphaCommand.commandName, "Router should route to the command with the given name")
            XCTAssert(args.unclassifiedArguments().count == 0, "Router should leave no arguments for the command")
        } catch {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    func testShortcutRoute() {
        let args = RawArguments(argumentString: "tester -b")
        let router = createRouter(arguments: args)
        
        do {
            let command = try router.route()
            XCTAssertEqual(command.commandName, betaCommand.commandName, "Router should route to the command with the given shortcut")
            XCTAssert(args.unclassifiedArguments().count == 0, "Router should leave no arguments for the command")
        } catch {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    func testDefaultCommandFlag() {
        let args = RawArguments(argumentString: "tester -a")
        let router = createRouter(arguments: args)
        
        do {
            let command = try router.route()
            XCTAssertEqual(command.commandName, defaultCommand.commandName, "Router should route to the default command when the flag does not match any command shortcut")
            XCTAssertEqual(args.unclassifiedArguments(), ["-a"], "Router should pass the flag on to the default command")
        } catch {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    func testFailedRoute() {
        let args = RawArguments(argumentString: "tester charlie")
        let router = createRouter(arguments: args)
        
        do {
            try router.route()
            XCTFail("Router should throw an error when the command does not exist")
        } catch {}
    }
    
    // MARK: - Helper
    
    private func createRouter(arguments arguments: RawArguments) -> Router {
        let commands = [alphaCommand, betaCommand, defaultCommand] as [CommandType]
        return Router(commands: commands, arguments: arguments, defaultCommand: defaultCommand)
    }
    
}
