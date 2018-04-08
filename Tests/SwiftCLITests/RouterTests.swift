//
//  RouterTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 1/7/15.
//  Copyright (c) 2015 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class ParserTests: XCTestCase {
    
    static var allTests : [(String, (ParserTests) -> () throws -> Void)] {
        return [
            ("testNameRoute", testNameRoute),
            ("testAliasRoute", testAliasRoute),
//            ("testSingleRouter", testSingleRouter),
            ("testFailedRoute", testFailedRoute),
            ("testGroupPartialRoute", testGroupPartialRoute),
            ("testGroupFailedRoute", testGroupFailedRoute),
            ("testGroupSuccessRoute", testGroupSuccessRoute),
            ("testNestedGroup", testNestedGroup)
        ]
    }
    
    // MARK: - Tests
    
    func testNameRoute() throws {
        let args = ArgumentList(argumentString: "tester alpha")
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        let command = try  DefaultParser(commandGroup: cli, arguments: args).parse()
        XCTAssert(command.groupPath.bottom === cli, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssert(command.command === alphaCmd, "Router should route to the command with the given name")
        XCTAssert(args.head == nil, "Router should leave no arguments for the command")
    }
    
    func testAliasRoute() throws {
        let args = ArgumentList(argumentString: "tester -b")
        
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        cli.aliases["-b"] = betaCmd.name
        
        let command = try DefaultParser(commandGroup: cli, arguments: args).parse()
        XCTAssertEqual(command.groupPath.bottom.name, cli.name, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssertEqual(command.command.name, betaCmd.name, "Router with enabled shortcut routing should route to the command with the given shortcut")
        
        XCTAssert(args.head == nil, "Enabled router should pass on no arguments to the matched command")
    }
    
//    func testSingleRouter() {
//        let args = ArgumentList(argumentString: "tester -a")
//        let cli = CLI.createTester(commands: [alphaCmd])
//
//        guard case let .success(command) = SingleCommandRouter(command: alphaCmd).route(cli: cli, arguments: args) else {
//            XCTFail()
//            return
//        }
//
//        XCTAssert(command.groupPath.bottom === cli, "Router should generate correct group path")
//        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
//        XCTAssert(command.command === alphaCmd, "Router should route to the single command")
//        XCTAssert(args.head?.value == "-a" && args.head?.next == nil, "Router should pass the flag on to the single command")
//    }
    
    func testFailedRoute() throws {
        let args = ArgumentList(argumentString: "tester charlie")
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        do {
            _ = try DefaultParser(commandGroup: cli, arguments: args).parse()
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.bottom === cli, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 1, "Router should generate correct group path")
            XCTAssertEqual(error.notFound, "charlie")
        }
    }
    
    func testGroupPartialRoute() throws {
        let arguments = ArgumentList(argumentString: "tester mid")
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        do {
            _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === midGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
    }
    
    func testGroupFailedRoute() throws {
        let arguments = ArgumentList(argumentString: "tester mid charlie")
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        do {
            _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === midGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertEqual(error.notFound, "charlie")
        }
    }
    
    func testGroupSuccessRoute() throws {
        let arguments = ArgumentList(argumentString: "tester mid beta")
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        let cmd = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        XCTAssert(cmd.groupPath.groups[0] === cli, "Router should generate correct group path")
        XCTAssert(cmd.groupPath.bottom === midGroup, "Router should generate correct group path")
        XCTAssertEqual(cmd.groupPath.groups.count, 2, "Router should generate correct group path")
        XCTAssert(cmd.command === betaCmd)
    }
    
    func testNestedGroup() throws {
        class Nested: CommandGroup {
            let name = "nested"
            let shortDescription = "Nested group"
            let children: [Routable] = [midGroup, intraGroup]
        }
        
        let nested = Nested()
        
        var arguments = ArgumentList(argumentString: "tester nested")
        let cli = CLI.createTester(commands: [nested])
        
        do {
            _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.bottom === nested, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
        
        arguments = ArgumentList(argumentString: "tester nested intra")
        do {
            _ = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === nested, "Router should generate correct group path")
            XCTAssert(error.partialPath.bottom === intraGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 3, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
        
        arguments = ArgumentList(argumentString: "tester nested intra delta")
        let cmd = try DefaultParser(commandGroup: cli, arguments: arguments).parse()
        
        XCTAssert(cmd.groupPath.groups[0] === cli, "Router should generate correct group path")
        XCTAssert(cmd.groupPath.groups[1] === nested, "Router should generate correct group path")
        XCTAssert(cmd.groupPath.bottom === intraGroup, "Router should generate correct group path")
        XCTAssertEqual(cmd.groupPath.groups.count, 3, "Router should generate correct group path")
        XCTAssert(cmd.command === deltaCmd)
    }
    
}
