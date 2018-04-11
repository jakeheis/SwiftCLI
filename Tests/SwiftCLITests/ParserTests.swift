//
//  ParserTests.swift
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
            ("testSingleRouter", testSingleRouter),
            ("testFailedRoute", testFailedRoute),
            ("testGroupPartialRoute", testGroupPartialRoute),
            ("testGroupFailedRoute", testGroupFailedRoute),
            ("testGroupSuccessRoute", testGroupSuccessRoute),
            ("testNestedGroup", testNestedGroup),
            ("testEmptySignature", testEmptySignature),
            ("testRequiredParameters", testRequiredParameters),
            ("testOptionalParameters", testOptionalParameters),
            ("testOptionalParametersWithInheritance", testOptionalParametersWithInheritance),
            ("testCollectedRequiredParameters", testCollectedRequiredParameters),
            ("testCollectedOptionalParameters", testCollectedOptionalParameters),
            ("testCombinedRequiredAndOptionalParameters", testCombinedRequiredAndOptionalParameters),
            ("testEmptyOptionalCollectedParameter", testEmptyOptionalCollectedParameter),
            ("testSimpleFlagParsing", testSimpleFlagParsing),
            ("testSimpleKeyParsing", testSimpleKeyParsing),
            ("testKeyValueParsing", testKeyValueParsing),
            ("testCombinedFlagsAndKeysParsing", testCombinedFlagsAndKeysParsing),
            ("testCombinedFlagsAndKeysAndArgumentsParsing", testCombinedFlagsAndKeysAndArgumentsParsing),
            ("testUnrecognizedOptions", testUnrecognizedOptions),
            ("testKeysNotGivenValues", testKeysNotGivenValues),
            ("testIllegalOptionFormat", testIllegalOptionFormat),
            ("testFlagSplitting", testFlagSplitting),
            ("testGroupRestriction", testGroupRestriction),
            ("testVaridadicParse", testVaridadicParse),
            ("testFullParse", testFullParse),
            ("testCollectedOptions", testCollectedOptions)
        ]
    }
    
    // MARK: - Routing tests
    
    func testNameRoute() throws {
        let args = ArgumentList(testString: "tester alpha")
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        let command = try Parser().parse(commandGroup: cli, arguments: args)
        XCTAssert(command.groupPath?.bottom === cli, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath?.groups.count, 1, "Router should generate correct group path")
        XCTAssert(command.command === alphaCmd, "Router should route to the command with the given name")
    }
    
    func testAliasRoute() throws {
        let args = ArgumentList(testString: "tester -b")
        
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        cli.aliases["-b"] = betaCmd.name
        
        let command = try Parser().parse(commandGroup: cli, arguments: args)
        XCTAssertEqual(command.groupPath?.bottom.name, cli.name, "Router should generate correct group path")
        XCTAssertEqual(command.groupPath?.groups.count, 1, "Router should generate correct group path")
        XCTAssertEqual(command.command.name, betaCmd.name, "Router with enabled shortcut routing should route to the command with the given shortcut")
    }
    
    func testSingleRouter() throws {
        let cmd = FlagCmd()
        let args = ArgumentList(testString: "tester -a")
        let cli = CLI.createTester(commands: [cmd])

        let path: CommandPath
        do {
            path = try Parser(router: SingleCommandRouter(command: cmd)).parse(commandGroup: cli, arguments: args)
        } catch let error {
            print(error)
            throw error
        }

        XCTAssert(path.groupPath?.bottom === cli, "Router should generate correct group path")
        XCTAssertEqual(path.groupPath?.groups.count, 1, "Router should generate correct group path")
        XCTAssert(path.command === cmd, "Router should route to the single command")
        XCTAssertTrue(cmd.flag.value)
    }
    
    func testFailedRoute() throws {
        let args = ArgumentList(testString: "tester charlie")
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        do {
            _ = try Parser().parse(commandGroup: cli, arguments: args)
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
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
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
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
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
        
        let cmd = try Parser().parse(commandGroup: cli, arguments: arguments)
        XCTAssert(cmd.groupPath?.groups[0] === cli, "Router should generate correct group path")
        XCTAssert(cmd.groupPath?.bottom === midGroup, "Router should generate correct group path")
        XCTAssertEqual(cmd.groupPath?.groups.count, 2, "Router should generate correct group path")
        XCTAssert(cmd.command === betaCmd)
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
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.bottom === nested, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 2, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
        
        arguments = ArgumentList(testString: "tester nested intra")
        do {
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as RouteError {
            XCTAssert(error.partialPath.groups[0] === cli, "Router should generate correct group path")
            XCTAssert(error.partialPath.groups[1] === nested, "Router should generate correct group path")
            XCTAssert(error.partialPath.bottom === intraGroup, "Router should generate correct group path")
            XCTAssertEqual(error.partialPath.groups.count, 3, "Router should generate correct group path")
            XCTAssertNil(error.notFound)
        }
        
        arguments = ArgumentList(testString: "tester nested intra delta")
        let cmd = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssert(cmd.groupPath?.groups[0] === cli, "Router should generate correct group path")
        XCTAssert(cmd.groupPath?.groups[1] === nested, "Router should generate correct group path")
        XCTAssert(cmd.groupPath?.bottom === intraGroup, "Router should generate correct group path")
        XCTAssertEqual(cmd.groupPath?.groups.count, 3, "Router should generate correct group path")
        XCTAssert(cmd.command === deltaCmd)
    }
    
    // MARK: - Parameter tests
    
    @discardableResult
    func parse<T: Command>(command: T, args: [String]) throws -> T {
        let cli = CLI.createTester(commands: [command])
        let arguments = ArgumentList(arguments: ["cmd"] + args)
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        return command
    }
    
    func testEmptySignature() throws {
        try parse(command: EmptyCmd(), args: [])
        
        do {
            try parse(command: EmptyCmd(), args: ["arg"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires exactly 0 arguments")
        }
    }
    
    func testRequiredParameters() throws {
        do {
            try parse(command: Req2Cmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires exactly 2 arguments")
        }
        
        let req2 = try parse(command: Req2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(req2.req1.value, "arg1")
        XCTAssertEqual(req2.req2.value, "arg2")
        
        do {
            try parse(command: Req2Cmd(), args: ["arg1", "arg2", "arg3"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires exactly 2 arguments")
        }
    }
    
    func testOptionalParameters() throws {
        let cmd1 = try parse(command: Opt2Cmd(), args: [])
        XCTAssertEqual(cmd1.opt1.value, nil)
        XCTAssertEqual(cmd1.opt2.value, nil)
        
        let cmd2 = try parse(command: Opt2Cmd(), args: ["arg1"])
        XCTAssertEqual(cmd2.opt1.value, "arg1")
        XCTAssertEqual(cmd2.opt2.value, nil)
        
        let cmd3 = try parse(command: Opt2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd3.opt1.value, "arg1")
        XCTAssertEqual(cmd3.opt2.value, "arg2")
        
        do {
            try parse(command: Opt2Cmd(), args: ["arg1", "arg2", "arg3"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires between 0 and 2 arguments")
        }
    }
    
    func testOptionalParametersWithInheritance() throws {
        let cmd1 = try parse(command: Opt2InhCmd(), args: [])
        XCTAssertEqual(cmd1.opt1.value, nil)
        XCTAssertEqual(cmd1.opt2.value, nil)
        XCTAssertEqual(cmd1.opt3.value, nil)
        
        let cmd2 = try parse(command: Opt2InhCmd(), args: ["arg1"])
        XCTAssertEqual(cmd2.opt1.value, "arg1")
        XCTAssertEqual(cmd2.opt2.value, nil)
        XCTAssertEqual(cmd2.opt3.value, nil)
        
        let cmd3 = try parse(command: Opt2InhCmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd3.opt1.value, "arg1")
        XCTAssertEqual(cmd3.opt2.value, "arg2")
        XCTAssertEqual(cmd3.opt3.value, nil)
        
        let cmd4 = try parse(command: Opt2InhCmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd4.opt1.value, "arg1")
        XCTAssertEqual(cmd4.opt2.value, "arg2")
        XCTAssertEqual(cmd4.opt3.value, "arg3")
        
        do {
            try parse(command: Opt2InhCmd(), args: ["arg1", "arg2", "arg3", "arg4"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires between 0 and 3 arguments")
        }
    }
    
    func testCollectedRequiredParameters() throws {
        do {
            try parse(command: ReqCollectedCmd(), args: [])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires at least 1 argument")
        }
        
        do {
            try parse(command: Req2CollectedCmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires at least 2 arguments")
        }
        
        let cmd1 = try parse(command: Req2CollectedCmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd1.req1.value, "arg1")
        XCTAssertEqual(cmd1.req2.value, ["arg2"])
        
        let cmd2 = try parse(command: Req2CollectedCmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd2.req1.value, "arg1")
        XCTAssertEqual(cmd2.req2.value, ["arg2", "arg3"])
    }
    
    func testCollectedOptionalParameters() throws {
        let cmd1 = try parse(command: Opt2CollectedCmd(), args: [])
        XCTAssertEqual(cmd1.opt1.value, nil)
        XCTAssertEqual(cmd1.opt2.value, [])
        
        let cmd2 = try parse(command: Opt2CollectedCmd(), args: ["arg1"])
        XCTAssertEqual(cmd2.opt1.value, "arg1")
        XCTAssertEqual(cmd2.opt2.value, [])
        
        let cmd3 = try parse(command: Opt2CollectedCmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd3.opt1.value, "arg1")
        XCTAssertEqual(cmd3.opt2.value, ["arg2"])
        
        let cmd4 = try parse(command: Opt2CollectedCmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd4.opt1.value, "arg1")
        XCTAssertEqual(cmd4.opt2.value, ["arg2", "arg3"])
    }
    
    func testCombinedRequiredAndOptionalParameters() throws {
        do {
            try parse(command: Req2Opt2Cmd(), args: ["arg1"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires between 2 and 4 arguments")
        }
        
        let cmd1 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2"])
        XCTAssertEqual(cmd1.req1.value, "arg1")
        XCTAssertEqual(cmd1.req2.value, "arg2")
        XCTAssertEqual(cmd1.opt1.value, nil)
        XCTAssertEqual(cmd1.opt2.value, nil)
        
        let cmd2 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3"])
        XCTAssertEqual(cmd2.req1.value, "arg1")
        XCTAssertEqual(cmd2.req2.value, "arg2")
        XCTAssertEqual(cmd2.opt1.value, "arg3")
        XCTAssertEqual(cmd2.opt2.value, nil)
        
        let cmd3 = try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3", "arg4"])
        XCTAssertEqual(cmd3.req1.value, "arg1")
        XCTAssertEqual(cmd3.req2.value, "arg2")
        XCTAssertEqual(cmd3.opt1.value, "arg3")
        XCTAssertEqual(cmd3.opt2.value, "arg4")
        
        do {
            try parse(command: Req2Opt2Cmd(), args: ["arg1", "arg2", "arg3", "arg4", "arg5"])
            XCTFail()
        } catch let error as ParameterError {
            XCTAssertEqual(error.message, "error: command requires between 2 and 4 arguments")
        }
    }
    
    func testEmptyOptionalCollectedParameter() throws { // Tests regression
        let cmd = try parse(command: OptCollectedCmd(), args: [])
        XCTAssertEqual(cmd.opt1.value, [])
    }
    
    // MARK: - Option parsing tests
    
    func testSimpleFlagParsing() throws {
        let cmd = DoubleFlagCmd()
        let arguments = ArgumentList(testString: "tester cmd -a -b")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        XCTAssert(cmd.alpha.value && cmd.beta.value, "Options should update the values of passed flags")
    }
    
    func testSimpleKeyParsing() throws {
        let cmd = DoubleKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -a apple -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssertEqual(cmd.alpha.value, "apple", "Options should update the values of passed keys")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should update the values of passed keys")
    }
    
    func testKeyValueParsing() throws {
        let cmd = IntKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -a 7")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssert(cmd.alpha.value == 7, "Options should parse int")
    }
    
    func testCombinedFlagsAndKeysParsing() throws {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -a -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssert(cmd.alpha.value, "Options should execute the closures of passed flags")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
    }
    
    func testCombinedFlagsAndKeysAndArgumentsParsing() throws {
        let cmd = FlagKeyParamCmd()
        let arguments = ArgumentList(testString: "tester cmd -a argument -b banana")
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssert(cmd.alpha.value, "Options should execute the closures of passed flags")
        XCTAssertEqual(cmd.beta.value, "banana", "Options should execute the closures of passed keys")
        XCTAssertEqual(cmd.param.value, "argument")
    }
    
    func testUnrecognizedOptions() throws {
        let cmd = FlagCmd()
        let arguments = ArgumentList(testString: "tester cmd -a -b")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Unrecognized option: -b")
        }
    }
    
    func testKeysNotGivenValues() throws {
        let cmd = FlagKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -b -a")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Expected a value to follow: -b")
        }
    }
    
    func testIllegalOptionFormat() throws {
        let cmd = IntKeyCmd()
        let arguments = ArgumentList(testString: "tester cmd -a val")
        let cli = CLI.createTester(commands: [cmd])
        
        do {
            _ = try Parser().parse(commandGroup: cli, arguments: arguments)
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Illegal type passed to -a: 'val'")
        }
    }
    
    func testFlagSplitting() throws {
        let cmd = DoubleFlagCmd()
        let arguments = ArgumentList(testString: "tester cmd -ab")
        OptionSplitter().manipulate(arguments: arguments)
        let cli = CLI.createTester(commands: [cmd])
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        
        XCTAssert(cmd.alpha.value && cmd.beta.value, "Options should execute the closures of passed flags")
    }
    
    func testGroupRestriction() throws {
        let cmd1 = ExactlyOneCmd()
        let arguments1 = ArgumentList(testString: "tester cmd -a -b")
        
        do {
            _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd1]), arguments: arguments1)
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Must pass exactly one of the following: --alpha --beta")
        }
        
        let cmd2 = ExactlyOneCmd()
        let arguments2 = ArgumentList(testString: "tester cmd -a")
        _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd2]), arguments: arguments2)
        XCTAssertTrue(cmd2.alpha.value)
        XCTAssertFalse(cmd2.beta.value)
        
        let cmd3 = ExactlyOneCmd()
        let arguments3 = ArgumentList(testString: "tester cmd -b")
        _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd3]), arguments: arguments3)
        XCTAssertTrue(cmd3.beta.value)
        XCTAssertFalse(cmd3.alpha.value)
        
        let cmd4 = ExactlyOneCmd()
        let arguments4 = ArgumentList(testString: "tester cmd")
        do {
            _ = try Parser().parse(commandGroup: CLI.createTester(commands: [cmd4]), arguments: arguments4)
            XCTFail()
        } catch let error as OptionError {
            XCTAssertEqual(error.message, "Must pass exactly one of the following: --alpha --beta")
        }
    }
    
    func testVaridadicParse() throws {
        let cmd = VariadicKeyCmd()
        let cli = CLI.createTester(commands: [cmd])
        let arguments = ArgumentList(testString: "tester cmd -f firstFile --file secondFile")
        
        _ = try Parser().parse(commandGroup: cli, arguments: arguments)
        XCTAssertEqual(cmd.files.values, ["firstFile", "secondFile"])
    }
    
    // MARK: - Combined test
    
    func testFullParse() throws {
        let cmd = TestCommand()
        let cli = CLI.createTester(commands: [cmd])
        
        let args = ArgumentList(arguments: ["test", "-s", "favTest", "-t", "3", "SwiftCLI"])
        let path = try Parser().parse(commandGroup: cli, arguments: args)
        
        XCTAssertEqual(path.joined(), "tester test")
        XCTAssertTrue(path.command === cmd)
        
        XCTAssertEqual(cmd.testName.value, "favTest")
        XCTAssertEqual(cmd.testerName.value, "SwiftCLI")
        XCTAssertTrue(cmd.silent.value)
        XCTAssertEqual(cmd.times.value, 3)
    }
    
    func testCollectedOptions() throws {
        class RunCmd: Command {
            let name = "run"
            let executable = Parameter()
            let args = OptionalCollectedParameter()
            let verbose = Flag("-v")
            func execute() throws {}
        }
        
        let cmd = RunCmd()
        let cli = CLI.createTester(commands: [cmd])
        let args = ArgumentList(testString: "tester run cli -v arg")
        
        let path = try Parser().parse(commandGroup: cli, arguments: args)
        XCTAssertEqual(path.joined(), "tester run")
        XCTAssertTrue(path.command === cmd)
        
        XCTAssertEqual(cmd.executable.value, "cli")
        XCTAssertEqual(cmd.args.value, ["-v", "arg"])
        XCTAssertFalse(cmd.verbose.value)
        
        let cmd2 = RunCmd()
        let cli2 = CLI.createTester(commands: [cmd2])
        let args2 = ArgumentList(testString: "tester run -v cli arg")
        
        let path2 = try Parser().parse(commandGroup: cli2, arguments: args2)
        XCTAssertEqual(path2.joined(), "tester run")
        XCTAssertTrue(path2.command === cmd2)
        
        XCTAssertEqual(cmd2.executable.value, "cli")
        XCTAssertEqual(cmd2.args.value, ["arg"])
        XCTAssertTrue(cmd2.verbose.value)
    }
    
}

extension ArgumentList {
    convenience init(testString: String) {
        self.init(argumentString: testString)
        pop()
    }
}
