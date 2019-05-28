//
//  CommandMessageGeneratorTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

import XCTest
@testable import SwiftCLI

class HelpMessageGeneratorTests: XCTestCase {
    
    // MARK: - HelpMessageGenerator.writeCommandList
    
    func testCommandListGeneration() {
        let capture = CaptureStream()
        let path = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, betaCmd], description: "A tester for SwiftCLI"))
        DefaultHelpMessageGenerator().writeCommandList(for: path, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester <command> [options]
        
        A tester for SwiftCLI
        
        Commands:
          alpha           The alpha command
          beta            A beta command
          help            Prints help information
        
        
        """)
        
        let capture2 = CaptureStream()
        let path2 = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, midGroup]))
        DefaultHelpMessageGenerator().writeCommandList(for: path2, to: capture2)
        capture2.closeWrite()
        
        XCTAssertEqual(capture2.readAll(), """
        
        Usage: tester <command> [options]
        
        Groups:
          mid             The mid level of commands
        
        Commands:
          alpha           The alpha command
          help            Prints help information
        
        
        """)
    }
    
    func testMutlineCommandListGeneration() {
        let capture = CaptureStream()
        let path = CommandGroupPath(top: CLI.createTester(commands: [MultilineCommand(), betaCmd], description: "A tester for SwiftCLI"))
        DefaultHelpMessageGenerator().writeCommandList(for: path, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """

        Usage: tester <command> [options]

        A tester for SwiftCLI

        Commands:
          test            A command that has multiline comments.
                          New line
          beta            A beta command
          help            Prints help information


        """)
    }
    
    // MARK: - HelpMessageGenerator.writeUsageStatement

    func testUsageStatementGeneration() {
        let capture = CaptureStream()
        let command = TestCommand()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]

        A command to test stuff
        
        Options:
          -h, --help             Show help information
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        
        """)
    }

    func testLongDescriptionGeneration() {
        let capture = CaptureStream()
        let command = TestCommandWithLongDescription()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: capture)
        capture.closeWrite()

        XCTAssertEqual(capture.readAll(), """

        Usage: tester test [options]

        This is a long
        multiline description

        Options:
          -h, --help      Show help information


        """)
    }
    
    func testInheritedUsageStatementGeneration() {
        let capture = CaptureStream()
        let cmd = TestInheritedCommand()
        let cli = CLI.createTester(commands: [cmd])
        let path = CommandGroupPath(top: cli).appending(cmd)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]

        A command to test stuff
        
        Options:
          -h, --help             Show help information
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
          -v, --verbose          Show more output information
        

        """)
    }
    
    func testMutlineUsageStatementGeneration() {
        let capture = CaptureStream()
        let command = MultilineCommand()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        DefaultHelpMessageGenerator().writeUsageStatement(for: path, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """

        Usage: tester test [options]

        A command that has multiline comments.
        New line

        Options:
          -h, --help             Show help information
          -s, --silent           Silence all test output
                                 Newline
          -t, --times <value>    Number of times to run the test


        """)
    }
    
    // MARK: - HelpMessageGenerator.writeRouteErrorMessage
    
    func testCommandNotSpecified() {
        let capture = CaptureStream()
        let path = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, betaCmd], description: "A tester for SwiftCLI"))
        DefaultHelpMessageGenerator().writeRouteErrorMessage(for: RouteError(partialPath: path, notFound: nil), to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester <command> [options]
        
        A tester for SwiftCLI
        
        Commands:
          alpha           The alpha command
          beta            A beta command
          help            Prints help information
        
        
        """)
    }
    
    func testCommandNotFound() {
        let capture = CaptureStream()
        let path = CommandGroupPath(top: CLI.createTester(commands: [alphaCmd, betaCmd], description: "A tester for SwiftCLI"))
        DefaultHelpMessageGenerator().writeRouteErrorMessage(for: RouteError(partialPath: path, notFound: "nope"), to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester <command> [options]
        
        A tester for SwiftCLI
        
        Commands:
          alpha           The alpha command
          beta            A beta command
          help            Prints help information
        
        Error: command 'nope' not found

        
        """)
    }
    
    // MARK: - HelpMessageGenerator.writeMisusedOptionsStatement
    
    func testMisusedOptionsStatementGeneration() {
        let capture = CaptureStream()
        let command = TestCommand()
        let path = CommandGroupPath(top: CLI.createTester(commands: [command])).appending(command)
        let error = OptionError(command: path, kind: .unrecognizedOption("-a"))
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: error, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]

        A command to test stuff
        
        Options:
          -h, --help             Show help information
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        Error: unrecognized option '-a'
        
        
        """)
    }
    
    func testNoCommandMisusedOption() {
        let capture = CaptureStream()
        let error = OptionError(command: nil, kind: .unrecognizedOption("-a"))
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: error, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Error: unrecognized option '-a'
        
        
        """)
    }
    
    func testExpectedValueAfterKey() {
        let capture = CaptureStream()
        let command = TestCommand()
        let path = CommandGroupPath(top: CLI.createTester(commands: [command])).appending(command)
        let error = OptionError(command: path, kind: .expectedValueAfterKey("-t"))
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: error, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]

        A command to test stuff
        
        Options:
          -h, --help             Show help information
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        Error: expected a value to follow '-t'
        
        
        """)
    }
    
    func testIllegalOptionType() {
        let capture = CaptureStream()
        let command = TestCommand()
        let path = CommandGroupPath(top: CLI.createTester(commands: [command])).appending(command)
        let error = OptionError(command: path, kind: .invalidKeyValue(command.times, "-t", .conversionError))
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: error, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester test <testName> [<testerName>] [options]

        A command to test stuff
        
        Options:
          -h, --help             Show help information
          -s, --silent           Silence all test output
          -t, --times <value>    Number of times to run the test
        
        Error: invalid value passed to '-t'; expected Int
        
        
        """)
    }
    
    func testInvalidOptionValue() {
        let capture = CaptureStream()
        let command = ValidatedKeyCmd()
        let path = CommandGroupPath(top: CLI.createTester(commands: [command])).appending(command)
        let error = OptionError(command: path, kind: .invalidKeyValue(command.location, "-l", .validationError(command.location.validation[0])))
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: error, to: capture)
        capture.closeWrite()
        
        XCTAssertEqualLineByLine(capture.readAll(), """
        
        Usage: tester cmd [options]

        Options:
          --holiday <value>         \n\
          -a, --age <value>         \n\
          -h, --help                Show help information
          -l, --location <value>    \n\
          -n, --name <value>        \n\

        Error: invalid value passed to '-l'; must not be: Chicago, Boston


        """)
    }
    
    func testOptionGroupMisuse() {
        let command = ExactlyOneCmd()
        let path = CommandGroupPath(top: CLI.createTester(commands: [command])).appending(command)
        
        let capture = CaptureStream()
        let error = OptionError(command: path, kind: .optionGroupMisuse(command.optionGroups[0]))
        DefaultHelpMessageGenerator().writeMisusedOptionsStatement(for: error, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        
        Usage: tester cmd [options]

        Options:
          -a, --alpha     the alpha flag
          -b, --beta      the beta flag
          -h, --help      Show help information

        Error: must pass exactly one of the following: --alpha --beta
        
        
        """)
    }
    
    // MARK: - HelpMessageGenerator.writeParameterErrorMessage
    
    func testParameterCountError() {
        let command = Req2Opt2Cmd()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        
        let capture = CaptureStream()
        let error = ParameterError(command: path, kind: .wrongNumber(2, 4))
        DefaultHelpMessageGenerator().writeParameterErrorMessage(for: error, to: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """

        Usage: tester cmd <req1> <req2> [<opt1>] [<opt2>] [options]

        Options:
          -h, --help      Show help information

        Error: command requires between 2 and 4 arguments
        
        
        """)
    }
    
    func testParameterTypeError() {
        let command = EnumCmd()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        
        let capture1 = CaptureStream()
        let error1 = ParameterError(command: path, kind: .invalidValue(.init(name: "speed", param: command.speed), .conversionError))
        DefaultHelpMessageGenerator().writeParameterErrorMessage(for: error1, to: capture1)
        capture1.closeWrite()
        
        #if swift(>=4.1.50)
        XCTAssertEqual(capture1.readAll(), """

        Usage: tester cmd <speed> [<single>] [<int>] [options]

        Limits param values to enum

        Options:
          -h, --help      Show help information

        Error: invalid value passed to 'speed'; expected one of: slow, fast
        
        
        """)
        #else
        XCTAssertEqual(capture1.readAll(), """

        Usage: tester cmd <speed> [<single>] [<int>] [options]

        Limits param values to enum

        Options:
          -h, --help      Show help information

        Error: invalid value passed to 'speed'; expected Speed


        """)
        #endif
        
        let capture2 = CaptureStream()
        let error2 = ParameterError(command: path, kind: .invalidValue(.init(name: "single", param: command.single), .conversionError))
        DefaultHelpMessageGenerator().writeParameterErrorMessage(for: error2, to: capture2)
        capture2.closeWrite()
        
        XCTAssertEqual(capture2.readAll(), """

        Usage: tester cmd <speed> [<single>] [<int>] [options]

        Limits param values to enum

        Options:
          -h, --help      Show help information

        Error: invalid value passed to 'single'; only can be 'value'
        
        
        """)
        
        let capture3 = CaptureStream()
        let error3 = ParameterError(command: path, kind: .invalidValue(.init(name: "int", param: command.int), .conversionError))
        DefaultHelpMessageGenerator().writeParameterErrorMessage(for: error3, to: capture3)
        capture3.closeWrite()
        
        XCTAssertEqual(capture3.readAll(), """

        Usage: tester cmd <speed> [<single>] [<int>] [options]

        Limits param values to enum

        Options:
          -h, --help      Show help information

        Error: invalid value passed to 'int'; expected Int
        
        
        """)
    }
    
    func testInvalidParameterValue() {
        let command = ValidatedParamCmd()
        let cli = CLI.createTester(commands: [command])
        let path = CommandGroupPath(top: cli).appending(command)
        
        let capture1 = CaptureStream()
        let error1 = ParameterError(command: path, kind: .invalidValue(.init(name: "age", param: command.age), .validationError(command.age.validation[0])))
        DefaultHelpMessageGenerator().writeParameterErrorMessage(for: error1, to: capture1)
        capture1.closeWrite()
        
        XCTAssertEqual(capture1.readAll(), """

        Usage: tester cmd [<age>] [options]

        Validates param values

        Options:
          -h, --help      Show help information

        Error: invalid value passed to 'age'; must be greater than 18
        
        
        """)
    }
    
    // MARK: -
    
    func testColoredError() {
        let cli = CLI.createTester(commands: [alphaCmd])
        let routeError = RouteError(partialPath: CommandGroupPath(top: cli), notFound: "missing")
        
        let plainCapture = CaptureStream()
        DefaultHelpMessageGenerator(colorError: false, boldError: false).writeRouteErrorMessage(for: routeError, to: plainCapture)
        plainCapture.closeWrite()
        XCTAssertEqual(plainCapture.readAll(), """
        
        Usage: tester <command> [options]
        
        Commands:
          alpha           The alpha command
          help            Prints help information

        Error: command 'missing' not found


        """)
        
        let colorCapture = CaptureStream()
        DefaultHelpMessageGenerator(colorError: true, boldError: false).writeRouteErrorMessage(for: routeError, to: colorCapture)
        colorCapture.closeWrite()
        XCTAssertEqual(colorCapture.readAll(), """
        
        Usage: tester <command> [options]

        Commands:
          alpha           The alpha command
          help            Prints help information

        \u{001B}[31mError: \u{001B}[0mcommand 'missing' not found
        

        """)
        
        let boldCapture = CaptureStream()
        DefaultHelpMessageGenerator(colorError: false, boldError: true).writeRouteErrorMessage(for: routeError, to: boldCapture)
        boldCapture.closeWrite()
        XCTAssertEqual(boldCapture.readAll(), """
        
        Usage: tester <command> [options]

        Commands:
          alpha           The alpha command
          help            Prints help information

        \u{001B}[1mError: \u{001B}[0mcommand 'missing' not found


        """)
        
        let bothCapture = CaptureStream()
        DefaultHelpMessageGenerator(colorError: true, boldError: true).writeRouteErrorMessage(for: routeError, to: bothCapture)
        bothCapture.closeWrite()
        XCTAssertEqual(bothCapture.readAll(), """
        
        Usage: tester <command> [options]

        Commands:
          alpha           The alpha command
          help            Prints help information

        \u{001B}[1m\u{001B}[31mError: \u{001B}[0mcommand 'missing' not found


        """)
    }
    
}
