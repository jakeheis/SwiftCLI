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
            ("testNameRoute", testNameRoute),
            ("testAliasRoute", testAliasRoute),
            ("testSingleRouter", testSingleRouter),
            ("testFailedRoute", testFailedRoute),
            ("testGroupPartialRoute", testGroupPartialRoute),
            ("testGroupFailedRoute", testGroupFailedRoute),
            ("testGroupSuccessRoute", testGroupSuccessRoute),
            ("testNestedGroup", testNestedGroup)
        ]
    }
    
    // MARK: - Tests
    
    func testNameRoute() {
        let args = ArgumentList(argumentString: "tester alpha")
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        guard case let .success(command) = DefaultRouter().route(cli: cli, arguments: args) else {
            XCTFail()
            return
        }
        XCTAssert(command.groupPath.bottom === cli, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssert(command.command === alphaCmd, "Router should route to the command with the given name")
        XCTAssert(args.head == nil, "Router should leave no arguments for the command")
    }
    
    func testAliasRoute() {
        let args = ArgumentList(argumentString: "tester -b")
        
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        cli.aliases["-b"] = betaCmd.name
        
        guard case let .success(command) = DefaultRouter().route(cli: cli, arguments: args) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(command.groupPath.bottom.name, cli.name, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssertEqual(command.command.name, betaCmd.name, "Router with enabled shortcut routing should route to the command with the given shortcut")
        
        XCTAssert(args.head == nil, "Enabled router should pass on no arguments to the matched command")
    }
    
    func testSingleRouter() {
        let args = ArgumentList(argumentString: "tester -a")
        let cli = CLI.createTester(commands: [alphaCmd])
        
        guard case let .success(command) = SingleCommandRouter(command: alphaCmd).route(cli: cli, arguments: args) else {
            XCTFail()
            return
        }
        
        XCTAssert(command.groupPath.bottom === cli, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssert(command.command === alphaCmd, "Router should route to the single command")
        XCTAssert(args.head?.value == "-a" && args.head?.next == nil, "Router should pass the flag on to the single command")
    }
    
    func testFailedRoute() {
        let args = ArgumentList(argumentString: "tester charlie")
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        if case let .failure(partialPath: partialPath, notFound: notFound) = DefaultRouter().route(cli: cli, arguments: args) {
            XCTAssert(partialPath.bottom === cli, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 1, "Router should generate correct group path")
            XCTAssertEqual(notFound, "charlie")
        } else {
            XCTFail()
        }
    }
    
    func testGroupPartialRoute() {
        let router = DefaultRouter()
        let routables: [Routable] = [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()]
        
        let arguments = ArgumentList(argumentString: "tester mid")
        let cli = CLI.createTester(commands: routables)
        let result = router.route(cli: cli, arguments: arguments)
        
        if case let .failure(partialPath: partialPath, notFound: notFound) = result {
            XCTAssert(partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(partialPath.groups[1] === midGroup, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(notFound)
        } else {
            XCTFail()
        }
    }
    
    func testGroupFailedRoute() {
        let arguments = ArgumentList(argumentString: "tester mid charlie")
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        if case let .failure(partialPath: partialPath, notFound: notFound) = DefaultRouter().route(cli: cli, arguments: arguments) {
            XCTAssert(partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(partialPath.groups[1] === midGroup, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertEqual(notFound, "charlie")
        } else {
            XCTFail()
        }
    }
    
    func testGroupSuccessRoute() {
        let arguments = ArgumentList(argumentString: "tester mid beta")
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        if case let .success(cmd) = DefaultRouter().route(cli: cli, arguments: arguments) {
            XCTAssert(cmd.groupPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(cmd.groupPath.bottom === midGroup, "Router should generate correct group path")
            XCTAssertEqual(cmd.groupPath.groups.count, 2, "Router should generate correct group path")
            XCTAssert(cmd.command === betaCmd)
        } else {
            XCTFail()
        }
    }
    
    func testNestedGroup() {
        class Nested: CommandGroup {
            let name = "nested"
            let shortDescription = "Nested group"
            let children: [Routable] = [midGroup, intraGroup]
        }
        
        let nested = Nested()
        
        var arguments = ArgumentList(argumentString: "tester nested")
        let cli = CLI.createTester(commands: [nested])
        
        if case let .failure(partialPath: partialPath, notFound: notFound) = DefaultRouter().route(cli: cli, arguments: arguments) {
            XCTAssert(partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(partialPath.bottom === nested, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(notFound)
        } else {
            XCTFail()
        }
        
        arguments = ArgumentList(argumentString: "tester nested intra")
        if case let .failure(partialPath: partialPath, notFound: notFound) = DefaultRouter().route(cli: cli, arguments: arguments) {
            XCTAssert(partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(partialPath.groups[1] === nested, "Router should generate correct group path")
            XCTAssert(partialPath.bottom === intraGroup, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 3, "Router should generate correct group path")
            XCTAssertNil(notFound)
        } else {
            XCTFail()
        }
        
        arguments = ArgumentList(argumentString: "tester nested intra delta")
        if case let .success(cmd) = DefaultRouter().route(cli: cli, arguments: arguments) {
            XCTAssert(cmd.groupPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(cmd.groupPath.groups[1] === nested, "Router should generate correct group path")
            XCTAssert(cmd.groupPath.bottom === intraGroup, "Router should generate correct group path")
            XCTAssertEqual(cmd.groupPath.groups.count, 3, "Router should generate correct group path")
            XCTAssert(cmd.command === deltaCmd)
        } else {
            XCTFail()
        }
    }
    
    // MARK: - Helper
    
//    private func routeCmd(_ arguments: ArgumentList, router: Router? = nil) -> CommandPath? {
//        if case let .success(cmd) = route(arguments, router: router) {
//            return cmd
//        }
//        return nil
//    }
//
//    private func route(_ arguments: ArgumentList, router: Router? = nil) -> RouteResult {
//        let router = router ?? DefaultRouter()
//        return router.route(cli: cli, arguments: arguments)
//    }
    
}
