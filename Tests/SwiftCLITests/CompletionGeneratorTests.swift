//
//  CompletionGeneratorTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 9/10/17.
//

import XCTest
@testable import SwiftCLI

class CompletionGeneratorTests: XCTestCase {
    
    func testGroup() {
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = CaptureStream()
        generator.writeGroup(for: CommandGroupPath(top: cli), into: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        _tester() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information]" \\
              '(-): :->command' \\
              '(-)*:: :->arg' && return
            case $state in
                (command)
                    local commands
                    commands=(
                    "alpha:The alpha command"
                    "beta:A beta command"
                    "help:Prints help information"
                    )
                    _describe 'command' commands
                    ;;
                (arg)
                    case ${words[1]} in
                        (alpha)
                            _tester_alpha
                            ;;
                        (beta)
                            _tester_beta
                            ;;
                        (help)
                            _tester_help
                            ;;
                    esac
                    ;;
            esac
        }
        _tester_alpha() {
            _arguments -C
        }
        _tester_beta() {
            _arguments -C
        }
        _tester_help() {
            _arguments -C \\
              "*::command: "
        }

        """)
    }
    
    func testBasicOptions() {
        let cmd = DoubleFlagCmd()
        let cli = CLI.createTester(commands: [cmd])
        
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = CaptureStream()
        let path = CommandGroupPath(top: cli).appending(cmd)
        generator.writeCommand(for: path, into: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        _tester_cmd() {
            _arguments -C \\
              '(-a --alpha)'{-a,--alpha}"[The alpha flag]" \\
              '(-b --beta)'{-b,--beta}"[The beta flag]"
        }
        
        """)
    }
    
    func testSepcialCaseOptionCompletion() {
        let variadicKey = VariadicKeyCmd()
        let exactlyOne = ExactlyOneCmd()
        let counterFlag = CounterFlagCmd()
        
        let cli = CLI.createTester(commands: [variadicKey, exactlyOne, counterFlag])
        let generator = ZshCompletionGenerator(cli: cli)
        
        let variadicKeyCapture = CaptureStream()
        generator.writeCommand(for: CommandGroupPath(top: cli).appending(variadicKey), into: variadicKeyCapture)
        variadicKeyCapture.closeWrite()
        XCTAssertEqual(variadicKeyCapture.readAll(), """
        _tester_cmd() {
            _arguments -C \\
              "*-f[a file]: :_files" \\
              "*--file[a file]: :_files"
        }
        
        """)
        
        let exactlyOneCapture = CaptureStream()
        generator.writeCommand(for: CommandGroupPath(top: cli).appending(exactlyOne), into: exactlyOneCapture)
        exactlyOneCapture.closeWrite()
        XCTAssertEqual(exactlyOneCapture.readAll(), """
        _tester_cmd() {
            _arguments -C \\
              '(-a --alpha -b --beta)'{-a,--alpha}"[the alpha flag]" \\
              '(-a --alpha -b --beta)'{-b,--beta}"[the beta flag]"
        }
        
        """)
        
        let counterFlagCapture = CaptureStream()
        generator.writeCommand(for: CommandGroupPath(top: cli).appending(counterFlag), into: counterFlagCapture)
        counterFlagCapture.closeWrite()
        XCTAssertEqual(counterFlagCapture.readAll(), """
        _tester_cmd() {
            _arguments -C \\
              "*-v[Increase the verbosity]" \\
              "*--verbose[Increase the verbosity]"
        }
        
        """)
    }
    
    func testParameterCompletion() {
        let req2 = Req2Cmd()
        let req2Collected = Req2CollectedCmd()
        let req2opt2 = Req2Opt2Cmd()
        
        let cli = CLI.createTester(commands: [req2, req2Collected, req2opt2])
        let generator = ZshCompletionGenerator(cli: cli)
        
        let req2Capture = CaptureStream()
        generator.writeCommand(for: CommandGroupPath(top: cli).appending(req2), into: req2Capture)
        req2Capture.closeWrite()
        
        XCTAssertEqual(req2Capture.readAll(), """
        _tester_cmd() {
            _arguments -C \\
              ":req1:_files" \\
              ":req2:{_values '' 'executable[generates a project for a cli executable]' 'library[generates project for a dynamic library]' 'other'}"
        }
        
        """)
        
        let req2CollectedCapture = CaptureStream()
        generator.writeCommand(for: CommandGroupPath(top: cli).appending(req2Collected), into: req2CollectedCapture)
        req2CollectedCapture.closeWrite()
        
        XCTAssertEqual(req2CollectedCapture.readAll(), """
        _tester_cmd() {
            _arguments -C \\
              ":req1:{_values '' 'executable[generates a project for a cli executable]' 'library[generates project for a dynamic library]'}" \\
              "*:req2:_files"
        }
        
        """)
        
        let req2opt2Capture = CaptureStream()
        generator.writeCommand(for: CommandGroupPath(top: cli).appending(req2opt2), into: req2opt2Capture)
        req2opt2Capture.closeWrite()
        
        XCTAssertEqual(req2opt2Capture.readAll(), """
        _tester_cmd() {
            _arguments -C \\
              ":req1:_files" \\
              ":req2:_swift_dependency" \\
              "::opt1: " \\
              "::opt2:_files"
        }
        
        """)
    }
    
    func testLayered() {
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd, intraGroup])
        
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = CaptureStream()
        generator.writeCompletions(into: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        #compdef tester
        local context state state_descr line
        typeset -A opt_args
        
        _tester() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information]" \\
              '(-): :->command' \\
              '(-)*:: :->arg' && return
            case $state in
                (command)
                    local commands
                    commands=(
                    "alpha:The alpha command"
                    "beta:A beta command"
                    "intra:The intra level of commands"
                    "help:Prints help information"
                    )
                    _describe 'command' commands
                    ;;
                (arg)
                    case ${words[1]} in
                        (alpha)
                            _tester_alpha
                            ;;
                        (beta)
                            _tester_beta
                            ;;
                        (intra)
                            _tester_intra
                            ;;
                        (help)
                            _tester_help
                            ;;
                    esac
                    ;;
            esac
        }
        _tester_alpha() {
            _arguments -C
        }
        _tester_beta() {
            _arguments -C
        }
        _tester_intra() {
            _arguments -C \\
              '(-): :->command' \\
              '(-)*:: :->arg' && return
            case $state in
                (command)
                    local commands
                    commands=(
                    "charlie:A beta command"
                    "delta:A beta command"
                    )
                    _describe 'command' commands
                    ;;
                (arg)
                    case ${words[1]} in
                        (charlie)
                            _tester_intra_charlie
                            ;;
                        (delta)
                            _tester_intra_delta
                            ;;
                    esac
                    ;;
            esac
        }
        _tester_intra_charlie() {
            _arguments -C
        }
        _tester_intra_delta() {
            _arguments -C
        }
        _tester_help() {
            _arguments -C \\
              "*::command: "
        }
        _tester
        
        """)
    }
    
    func testEscaping() {
        let cmd = QuoteDesciptionCmd()
        
        let cli = CLI.createTester(commands: [cmd])
        let generator = ZshCompletionGenerator(cli: cli)
        
        let capture = CaptureStream()
        generator.writeGroup(for: CommandGroupPath(top: cli), into: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        _tester() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information]" \\
              '(-): :->command' \\
              '(-)*:: :->arg' && return
            case $state in
                (command)
                    local commands
                    commands=(
                    "cmd:this description has a \\"quoted section\\""
                    "help:Prints help information"
                    )
                    _describe 'command' commands
                    ;;
                (arg)
                    case ${words[1]} in
                        (cmd)
                            _tester_cmd
                            ;;
                        (help)
                            _tester_help
                            ;;
                    esac
                    ;;
            esac
        }
        _tester_cmd() {
            _arguments -C \\
              '(-q --quoted)'{-q,--quoted}"[also has \\"quotes\\"]"
        }
        _tester_help() {
            _arguments -C \\
              "*::command: "
        }
        
        """)
    }
    
    func testFunction() {
        let body = """
        echo wassup
        """
        
        let cmd = Req1Cmd()
        
        let cli = CLI.createTester(commands: [cmd])
        let generator = ZshCompletionGenerator(cli: cli, functions: [
            "_ice_targets": body
        ])
        
        let justFunctionCapture = CaptureStream()
        generator.writeFunction(name: "_ice_targets", body: body, into: justFunctionCapture)
        justFunctionCapture.closeWrite()
        
        XCTAssertEqual(justFunctionCapture.readAll(), """
        _ice_targets() {
            echo wassup
        }
        
        """)
        
        let fullCapture = CaptureStream()
        generator.writeCompletions(into: fullCapture)
        fullCapture.closeWrite()
        
        XCTAssertEqual(fullCapture.readAll(), """
        #compdef tester
        local context state state_descr line
        typeset -A opt_args

        _tester() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information]" \\
              '(-): :->command' \\
              '(-)*:: :->arg' && return
            case $state in
                (command)
                    local commands
                    commands=(
                    "cmd:"
                    "help:Prints help information"
                    )
                    _describe 'command' commands
                    ;;
                (arg)
                    case ${words[1]} in
                        (cmd)
                            _tester_cmd
                            ;;
                        (help)
                            _tester_help
                            ;;
                    esac
                    ;;
            esac
        }
        _tester_cmd() {
            _arguments -C \\
              ":req1:_ice_targets"
        }
        _tester_help() {
            _arguments -C \\
              "*::command: "
        }
        _ice_targets() {
            echo wassup
        }
        _tester
        
        """)
    }
    
    func testOptionCompletion() {
        let cmd = CompletionOptionCmd()
        
        let cli = CLI.createTester(commands: [cmd])
        let generator = ZshCompletionGenerator(cli: cli)
        
        let capture = CaptureStream()
        generator.writeCommand(for: CommandGroupPath(top: cli).appending(cmd), into: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        _tester_cmd() {
            _arguments -C \\
              '(-v --values)'{-v,--values}"[]: :{_values '' 'opt1[first option]' 'opt2[second option]'}" \\
              '(-f --function)'{-f,--function}"[]: :_a_func" \\
              '(-n --name)'{-n,--name}"[]: :_files" \\
              '(-z --zero)'{-z,--zero}"[]: : " \\
              '(-d --default)'{-d,--default}"[]: :_files" \\
              '(-f --flag)'{-f,--flag}"[]"
        }
        
        """)
    }
    
}

