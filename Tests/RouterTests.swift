//
//  RouterTests.swift
//  Example
//
//  Created by Jake Heiser on 1/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import Cocoa
import XCTest
@testable import SwiftCLI

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
        
        do {
            let command = try route(args, router: DefaultRouter(defaultCommand: defaultCommand))
            XCTAssertEqual(command.commandName, defaultCommand.commandName, "Router should route to the default command if no arguments are given")
            XCTAssert(args.unclassifiedArguments().count == 0, "Router should leave no arguments for the command")
        } catch {
             XCTFail("Router should not fail when a default command exists")
        }
    }
    
    func testNameRoute() {
        let args = RawArguments(argumentString: "tester alpha")
        
        do {
            let command = try route(args)
            XCTAssertEqual(command.commandName, alphaCommand.commandName, "Router should route to the command with the given name")
            XCTAssert(args.unclassifiedArguments().count == 0, "Router should leave no arguments for the command")
        } catch {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    func testDefaultCommandFlag() {
        let args = RawArguments(argumentString: "tester -a")
        
        do {
            let command = try route(args, router: DefaultRouter(defaultCommand: defaultCommand))
            XCTAssertEqual(command.commandName, defaultCommand.commandName, "Router should route to the default command when the flag does not match any command shortcut")
            XCTAssertEqual(args.unclassifiedArguments(), ["-a"], "Router should pass the flag on to the default command")
        } catch {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    func testFailedRoute() {
        let args = RawArguments(argumentString: "tester charlie")
        
        do {
            try route(args)
            XCTFail("Router should throw an error when the command does not exist")
        } catch {}
    }
    
    func testEnableShortcutRouting() {
        let args = RawArguments(argumentString: "tester -b")
        
        do {
            let command = try route(args)
            
            XCTAssertEqual(command.commandName, betaCommand.commandName, "Router with enabled shortcut routing should route to the command with the given shortcut")
            
            XCTAssertEqual(args.unclassifiedArguments(), [], "Enabled router should pass on no arguments to the matched command")
        } catch {
            XCTFail("Router should not fail when the command exists")
        }
    }
    
    // MARK: - Helper
    
    private func route(arguments: RawArguments, router: RouterType? = nil) throws -> CommandType {
        let commands = [alphaCommand, betaCommand, defaultCommand] as [CommandType]
        let router = router ?? DefaultRouter()
        return try router.route(commands, arguments: arguments)
    }
    
}
