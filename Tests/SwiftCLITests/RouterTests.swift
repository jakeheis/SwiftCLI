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
        let args = ArgumentList(arguments: ["alpha"])
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        let command = try Parser().parse(cli: cli, arguments: args)
        XCTAssert(command.groupPath.bottom === cli, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssert(command.command === alphaCmd, "Router should route to the command with the given name")
        XCTAssertFalse(args.hasNext())
    }
    
    func testAliasRoute() throws {
        let args = ArgumentList(arguments: ["-b"])
        
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        cli.aliases["-b"] = betaCmd.name
        
        let command = try Parser().parse(cli: cli, arguments: args)
        XCTAssertEqual(command.groupPath.bottom.name, cli.name, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath.groups.count, 1, "Router should generate correct group path")
        XCTAssertEqual(command.command.name, betaCmd.name, "Router with enabled shortcut routing should route to the command with the given shortcut")
        XCTAssertFalse(args.hasNext())
    }
    
    func testSingleRouter() throws {
        var parser = Parser()
        
        let cmd = FlagCmd()
        let cli = CLI.createTester(commands: [cmd])
        parser.routeBehavior = .automatically(cmd)
        let path = try parser.parse(cli: cli, arguments: ArgumentList(arguments: ["-a"]))
        
        XCTAssert(path.groupPath.bottom === cli, "Router should generate correct group path")
        XCTAssertTrue(path.ignoreName)
        XCTAssert(path.command === cmd, "Router should route to the single command")
        XCTAssertTrue(cmd.flag)
        
        let cmd2 = FlagCmd()
        let cli2 = CLI.createTester(commands: [cmd2])
        parser.routeBehavior = .automatically(cmd2)
        let path2 = try parser.parse(cli: cli2, arguments: ArgumentList(arguments: []))
        
        XCTAssert(path2.groupPath.bottom === cli2, "Router should generate correct group path")
        XCTAssertTrue(path2.ignoreName)
        XCTAssert(path2.command === cmd2, "Router should route to the single command")
        XCTAssertFalse(cmd2.flag)
    }
    
    func testFallbackOption() throws {
        var parser = Parser()
        
        let cmd = FlagCmd()
        let cli = CLI.createTester(commands: [cmd])
        parser.routeBehavior = .searchWithFallback(cmd)
        let path = try parser.parse(cli: cli, arguments: ArgumentList(arguments: ["-a"]))
        
        XCTAssert(path.groupPath.bottom === cli, "Router should generate correct group path")
        XCTAssertTrue(path.ignoreName)
        XCTAssert(path.command === cmd, "Router should route to the single command")
        XCTAssertTrue(cmd.flag)
        
        let cmd2 = FlagCmd()
        let cli2 = CLI.createTester(commands: [cmd2])
        parser.routeBehavior = .searchWithFallback(cmd2)
        let path2 = try parser.parse(cli: cli2, arguments: ArgumentList(arguments: []))
        
        XCTAssert(path2.groupPath.bottom === cli2, "Router should generate correct group path")
        XCTAssertTrue(path2.ignoreName)
        XCTAssert(path2.command === cmd2, "Router should route to the single command")
        XCTAssertFalse(cmd2.flag)
    }
    
    func testFailedRoute() throws {
        let args = ArgumentList(arguments: ["charlie"])
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        do {
            _ = try Parser().parse(cli: cli, arguments: args)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.bottom === cli, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 1, "Router should generate correct group path")
            XCTAssertEqual(error.notFound, "charlie")
        }
    }
    
    func testGroupPartialRoute() throws {
        let arguments = ArgumentList(arguments: ["mid"])
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        do {
            _ = try Parser().parse(cli: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === midGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
    }
    
    func testGroupFailedRoute() throws {
        let arguments = ArgumentList(arguments: ["mid", "charlie"])
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        do {
            _ = try Parser().parse(cli: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === midGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertEqual(error.notFound, "charlie")
        }
    }
    
    func testGroupSuccessRoute() throws {
        let arguments = ArgumentList(arguments: ["mid", "beta"])
        let cli = CLI.createTester(commands: [midGroup, intraGroup, Req2Cmd(), Opt2Cmd()])
        
        let cmd = try Parser().parse(cli: cli, arguments: arguments)
        XCTAssert(cmd.groupPath.groups[0] === cli, "Router should generate correct group path")
        XCTAssert(cmd.groupPath.bottom === midGroup, "Router should generate correct group path")
        XCTAssertEqual(cmd.groupPath.groups.count, 2, "Router should generate correct group path")
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
        
        var arguments = ArgumentList(arguments: ["nested"])
        let cli = CLI.createTester(commands: [nested])
        
        do {
            _ = try Parser().parse(cli: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.bottom === nested, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
        
        arguments = ArgumentList(arguments: ["nested", "intra"])
        do {
            _ = try Parser().parse(cli: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === nested, "Router should generate correct group path")
            XCTAssert(error.partialPath.bottom === intraGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 3, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
        
        arguments = ArgumentList(arguments: ["nested", "intra", "delta"])
        let cmd = try Parser().parse(cli: cli, arguments: arguments)
        
        XCTAssert(cmd.groupPath.groups[0] === cli, "Router should generate correct group path")
        XCTAssert(cmd.groupPath.groups[1] === nested, "Router should generate correct group path")
        XCTAssert(cmd.groupPath.bottom === intraGroup, "Router should generate correct group path")
        XCTAssertEqual(cmd.groupPath.groups.count, 3, "Router should generate correct group path")
        XCTAssert(cmd.command === deltaCmd)
        XCTAssertFalse(arguments.hasNext())
    }

    func testFallback() throws {
        func setup() -> (Opt1Cmd, CLI, Parser) {
            let opt1 = Opt1Cmd()
            let cli = CLI.createTester(commands: [opt1])
            var parser = Parser()
            parser.routeBehavior = .searchWithFallback(opt1)
            return (opt1, cli, parser)
        }
        
        let (opt1, cli1, parser1) = setup()
        
        let firstResult = try parser1.parse(cli: cli1, arguments: ArgumentList(arguments: ["cmd", "value"]))
        XCTAssert(opt1 === firstResult.command)
        XCTAssertFalse(firstResult.ignoreName)
        XCTAssertEqual(opt1.opt1, "value")
        
        let (opt2, cli2, parser2) = setup()
        
        let secondResult = try parser2.parse(cli: cli2, arguments: ArgumentList(arguments: ["value2"]))
        XCTAssert(opt2 === secondResult.command)
        XCTAssertTrue(secondResult.ignoreName)
        XCTAssertEqual(opt2.opt1, "value2")
        
        let (opt3, cli3, parser3) = setup()
        
        let thirdResult = try parser3.parse(cli: cli3, arguments: ArgumentList(arguments: []))
        XCTAssert(opt3 === thirdResult.command)
        XCTAssertTrue(thirdResult.ignoreName)
        XCTAssertNil(opt3.opt1)
    }
    
}

