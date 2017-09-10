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
        XCTAssertEqual(command.name, alphaCmd.name, "Router should route to the command with the given name")
        XCTAssert(args.head == nil, "Router should leave no arguments for the command")
    }
    
    func testAliasRoute() {
        let args = ArgumentList(argumentString: "tester -b")
        
        CommandAliaser.alias(from: "-b", to: "beta")
        CommandAliaser().manipulate(arguments: args)
        
        guard let command = routeCmd(args) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(command.name, betaCmd.name, "Router with enabled shortcut routing should route to the command with the given shortcut")
        
        XCTAssert(args.head == nil, "Enabled router should pass on no arguments to the matched command")
    }
    
    func testSingleRouter() {
        let args = ArgumentList(argumentString: "tester -a")
        
        guard let command = routeCmd(args, router: SingleCommandRouter(command: alphaCmd)) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(command.name, alphaCmd.name, "Router should route to the single command")
        XCTAssert(args.head?.value == "-a" && args.head?.next == nil, "Router should pass the flag on to the single command")
    }
    
    func testFailedRoute() {
        CLI.name = "tester"
        let args = ArgumentList(argumentString: "tester charlie")
        
        let result = route(args)
        if case let .failure(partialPath: partialPath, group: group, attempted: attempted) = result {
            XCTAssertEqual(partialPath, "tester")
            XCTAssertNil(group)
            XCTAssertEqual(attempted, "charlie")
        } else {
            XCTFail()
        }
    }
    
    func testGroupPartialRoute() {
        let router = DefaultRouter()
        let routables: [Routable] = [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()]
        
        CLI.name = "tester"
        let arguments = ArgumentList(argumentString: "tester mid")
        let result = router.route(routables: routables, arguments: arguments)
        
        if case let .failure(partialPath: partialPath, group: group, attempted: attempted) = result {
            XCTAssertEqual(partialPath, "tester mid")
            if let group = group as? MidGroup {
                XCTAssert(group === midGroup)
            } else {
                XCTFail()
            }
            XCTAssertNil(attempted)
        } else {
            XCTFail()
        }
    }
    
    func testGroupFailedRoute() {
        let router = DefaultRouter()
        let routables: [Routable] = [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()]
        
        CLI.name = "tester"
        let arguments = ArgumentList(argumentString: "tester mid charlie")
        let result = router.route(routables: routables, arguments: arguments)
        
        if case let .failure(partialPath: partialPath, group: group, attempted: attempted) = result {
            XCTAssertEqual(partialPath, "tester mid")
            if let group = group as? MidGroup {
                XCTAssert(group === midGroup)
            } else {
                XCTFail()
            }
            XCTAssertEqual(attempted, "charlie")
        } else {
            XCTFail()
        }
    }
    
    func testGroupSuccessRoute() {
        let router = DefaultRouter()
        let routables: [Routable] = [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()]
        
        CLI.name = "tester"
        let arguments = ArgumentList(argumentString: "tester mid beta")
        let result = router.route(routables: routables, arguments: arguments)
        
        if case let .success(cmd) = result {
            XCTAssert(cmd === betaCmd)
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
        CLI.name = "tester"
        
        var arguments = ArgumentList(argumentString: "tester nested")
        var result = router.route(routables: [nested], arguments: arguments)
        if case let .failure(partialPath: partialPath, group: group, attempted: attempted) = result {
            XCTAssertEqual(partialPath, "tester nested")
            if let group = group as? Nested {
                XCTAssert(group === nested)
            } else {
                XCTFail()
            }
            XCTAssertNil(attempted)
        } else {
            XCTFail()
        }
        
        arguments = ArgumentList(argumentString: "tester nested intra")
        result = router.route(routables: [nested], arguments: arguments)
        if case let .failure(partialPath: partialPath, group: group, attempted: attempted) = result {
            XCTAssertEqual(partialPath, "tester nested intra")
            if let group = group as? IntraGroup {
                XCTAssert(group === intraGroup)
            } else {
                XCTFail()
            }
            XCTAssertNil(attempted)
        } else {
            XCTFail()
        }
        
        arguments = ArgumentList(argumentString: "tester nested intra delta")
        result = router.route(routables: [nested], arguments: arguments)
        if case let .success(cmd) = result {
            XCTAssert(cmd === deltaCmd)
        } else {
            XCTFail()
        }
    }
    
    // MARK: - Helper
    
    private func routeCmd(_ arguments: ArgumentList, router: Router? = nil) -> Command? {
        if case let .success(cmd) = route(arguments, router: router) {
            return cmd
        }
        return nil
    }
    
    private func route(_ arguments: ArgumentList, router: Router? = nil) -> RouteResult {
        let commands = [alphaCmd, betaCmd] as [Command]
        
        let router = router ?? DefaultRouter()
        return router.route(routables: commands, arguments: arguments)
    }
    
}
