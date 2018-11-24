//
//  RouterTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 4/18/18.
//

import XCTest
import SwiftCLI

class RouterTests: XCTestCase {

    func testNameRoute() throws {
        let args = ArgumentList(testString: "tester alpha")
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        let (command, _) = try DefaultRouter().parse(commandGroup: cli, arguments: args)
        XCTAssert(command.groupPath?.bottom === cli, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath?.groups.count, 1, "Router should generate correct group path")
        XCTAssert(command.command === alphaCmd, "Router should route to the command with the given name")
        XCTAssertFalse(args.hasNext())
    }
    
    func testAliasRoute() throws {
        let args = ArgumentList(testString: "tester -b")
        
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        cli.aliases["-b"] = betaCmd.name
        
        let (command, _) = try DefaultRouter().parse(commandGroup: cli, arguments: args)
        XCTAssertEqual(command.groupPath?.bottom.name, cli.name, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath?.groups.count, 1, "Router should generate correct group path")
        XCTAssertEqual(command.command.name, betaCmd.name, "Router with enabled shortcut routing should route to the command with the given shortcut")
        XCTAssertFalse(args.hasNext())
    }
    
    func testSingleRouter() throws {
        let cmd = FlagCmd()
        let args = ArgumentList(testString: "tester -a")
        let cli = CLI.createTester(commands: [cmd])
        
        let (path, _) = try SingleCommandRouter(command: cmd).parse(commandGroup: cli, arguments: args)
        
        XCTAssertNil(path.groupPath, "Router should generate correct group path")
        XCTAssert(path.command === cmd, "Router should route to the single command")
        XCTAssertEqual(args.pop(), "-a")
    }
    
    func testFailedRoute() throws {
        let args = ArgumentList(testString: "tester charlie")
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        do {
            _ = try DefaultRouter().parse(commandGroup: cli, arguments: args)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.bottom === cli, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 1, "Router should generate correct group path")
            XCTAssertEqual(error.notFound, "charlie")
        }
    }
    
    func testGroupPartialRoute() throws {
        let arguments = ArgumentList(testString: "tester mid")
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        do {
            _ = try DefaultRouter().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === midGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
    }
    
    func testGroupFailedRoute() throws {
        let arguments = ArgumentList(testString: "tester mid charlie")
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        do {
            _ = try DefaultRouter().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === midGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertEqual(error.notFound, "charlie")
        }
    }
    
    func testGroupSuccessRoute() throws {
        let arguments = ArgumentList(testString: "tester mid beta")
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        let (cmd, _) = try DefaultRouter().parse(commandGroup: cli, arguments: arguments)
        XCTAssert(cmd.groupPath?.groups[0] === cli, "Router should generate correct group path")
        XCTAssert(cmd.groupPath?.bottom === midGroup, "Router should generate correct group path")
        XCTAssertEqual(cmd.groupPath?.groups.count, 2, "Router should generate correct group path")
        XCTAssert(cmd.command === betaCmd)
        XCTAssertFalse(arguments.hasNext())
    }
    
    func testNestedGroup() throws {
        class Nested: CommandGroup {
            let name = "nested"
            let shortDescription = "Nested group"
            let children: [Routable] = [midGroup, intraGroup]
        }
        
        let nested = Nested()
        
        var arguments = ArgumentList(testString: "tester nested")
        let cli = CLI.createTester(commands: [nested])
        
        do {
            _ = try DefaultRouter().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.bottom === nested, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
        
        arguments = ArgumentList(testString: "tester nested intra")
        do {
            _ = try DefaultRouter().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === nested, "Router should generate correct group path")
            XCTAssert(error.partialPath.bottom === intraGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 3, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
        
        arguments = ArgumentList(testString: "tester nested intra delta")
        let (cmd, _) = try DefaultRouter().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssert(cmd.groupPath?.groups[0] === cli, "Router should generate correct group path")
        XCTAssert(cmd.groupPath?.groups[1] === nested, "Router should generate correct group path")
        XCTAssert(cmd.groupPath?.bottom === intraGroup, "Router should generate correct group path")
        XCTAssertEqual(cmd.groupPath?.groups.count, 3, "Router should generate correct group path")
        XCTAssert(cmd.command === deltaCmd)
        XCTAssertFalse(arguments.hasNext())
    }

}
