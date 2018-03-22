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
            ("testSingleRouter", testSingleRouter),
            ("testFailedRoute", testFailedRoute),
            ("testGroupPartialRoute", testGroupPartialRoute),
            ("testGroupFailedRoute", testGroupFailedRoute),
            ("testGroupSuccessRoute", testGroupSuccessRoute),
            ("testNestedGroup", testNestedGroup)
        ]
    }
    
    let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
    
    // MARK: - Tests
    
    func testNoRoute() {
        let args = ArgumentList(argumentString: "tester")
        
        let command = routeCmd(args)
        XCTAssert(command == nil)
    }
    
    func testNameRoute() {
        let args = ArgumentList(argumentString: "tester alpha")
        
        guard let command = routeCmd(args) else {
            XCTFail()
            return
        }
        XCTAssertEqual(command.groupPath.bottom.name, cli.name, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssertEqual(command.command.name, alphaCmd.name, "Router should route to the command with the given name")
        XCTAssert(args.head == nil, "Router should leave no arguments for the command")
    }
    
    func testAliasRoute() {
        let args = ArgumentList(argumentString: "tester -b")
        
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        cli.aliases["-b"] = betaCmd.name
        
        let result = DefaultRouter().route(cli: cli, arguments: args)
        guard case let .success(command) = result else {
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
        
        guard let command = routeCmd(args, router: SingleCommandRouter(command: alphaCmd)) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(command.groupPath.bottom.name, cli.name, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssertEqual(command.command.name, alphaCmd.name, "Router should route to the single command")
        XCTAssert(args.head?.value == "-a" && args.head?.next == nil, "Router should pass the flag on to the single command")
    }
    
    func testFailedRoute() {
        let args = ArgumentList(argumentString: "tester charlie")
        
        let result = route(args)
        if case let .failure(partialPath: partialPath, notFound: notFound) = result {
            XCTAssertEqual(partialPath.bottom.name, cli.name, "Router should generate correct group path")
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
        let result = router.route(cli: CLI.createTester(commands: routables), arguments: arguments)
        
        if case let .failure(partialPath: partialPath, notFound: notFound) = result {
            XCTAssertEqual(partialPath.cli.name, cli.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.bottom.name, midGroup.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(notFound)
        } else {
            XCTFail()
        }
    }
    
    func testGroupFailedRoute() {
        let router = DefaultRouter()
        let routables: [Routable] = [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()]
        
        let arguments = ArgumentList(argumentString: "tester mid charlie")
        let result = router.route(cli: CLI.createTester(commands: routables), arguments: arguments)
        
        if case let .failure(partialPath: partialPath, notFound: notFound) = result {
            XCTAssertEqual(partialPath.cli.name, cli.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.bottom.name, midGroup.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertEqual(notFound, "charlie")
        } else {
            XCTFail()
        }
    }
    
    func testGroupSuccessRoute() {
        let router = DefaultRouter()
        let routables: [Routable] = [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()]
        
        let arguments = ArgumentList(argumentString: "tester mid beta")
        let result = router.route(cli: CLI.createTester(commands: routables), arguments: arguments)
        
        if case let .success(cmd) = result {
            XCTAssertEqual(cmd.groupPath.cli.name, cli.name, "Router should generate correct group path")
            XCTAssertEqual(cmd.groupPath.bottom.name, midGroup.name, "Router should generate correct group path")
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
        let router = DefaultRouter()
        
        var arguments = ArgumentList(argumentString: "tester nested")
        var result = router.route(cli: CLI.createTester(commands: [nested]), arguments: arguments)
        if case let .failure(partialPath: partialPath, notFound: notFound) = result {
            XCTAssertEqual(partialPath.cli.name, cli.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.bottom.name, nested.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(notFound)
        } else {
            XCTFail()
        }
        
        arguments = ArgumentList(argumentString: "tester nested intra")
        result = router.route(cli: CLI.createTester(commands: [nested]), arguments: arguments)
        if case let .failure(partialPath: partialPath, notFound: notFound) = result {
            XCTAssertEqual(partialPath.cli.name, cli.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups[1].name, nested.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.bottom.name, intraGroup.name, "Router should generate correct group path")
            XCTAssertEqual(partialPath.groups.count, 3, "Router should generate correct group path")
            XCTAssertNil(notFound)
        } else {
            XCTFail()
        }
        
        arguments = ArgumentList(argumentString: "tester nested intra delta")
        result = router.route(cli: CLI.createTester(commands: [nested]), arguments: arguments)
        if case let .success(cmd) = result {
            XCTAssertEqual(cmd.groupPath.cli.name, cli.name, "Router should generate correct group path")
            XCTAssertEqual(cmd.groupPath.groups[1].name, nested.name, "Router should generate correct group path")
            XCTAssertEqual(cmd.groupPath.bottom.name, intraGroup.name, "Router should generate correct group path")
            XCTAssertEqual(cmd.groupPath.groups.count, 3, "Router should generate correct group path")
            XCTAssert(cmd.command === deltaCmd)
        } else {
            XCTFail()
        }
    }
    
    // MARK: - Helper
    
    private func routeCmd(_ arguments: ArgumentList, router: Router? = nil) -> CommandPath? {
        if case let .success(cmd) = route(arguments, router: router) {
            return cmd
        }
        return nil
    }
    
    private func route(_ arguments: ArgumentList, router: Router? = nil) -> RouteResult {
        let router = router ?? DefaultRouter()
        return router.route(cli: cli, arguments: arguments)
    }
    
}
