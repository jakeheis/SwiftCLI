//
//  CompletionGeneratorTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 9/10/17.
//

import XCTest
@testable import SwiftCLI

extension CLI {
    static func createTester(commands: [Routable], description: String? = nil) -> CLI {
        return CLI(name: "tester", description: description, commands: commands)
    }
}

class CompletionGeneratorTests: XCTestCase {
    
    static var allTests : [(String, (CompletionGeneratorTests) -> () throws -> Void)] {
        return [
            ("testCommandList", testCommandList),
            ("testOptions", testOptions),
            ("testFull", testFull)
        ]
    }
    
    func testCommandList() {
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd])
        
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = PipeStream()
        generator.writeCommandList(for: CommandGroupPath(top: cli), into: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        __tester_commands() {
             _arguments -C \\
               ': :->command'
             case "$state" in
                  command)
                       local -a commands
                       commands=(
                       alpha"[The alpha command]"
                       beta"[A beta command]"
                       )
                       _values 'command' $commands
                       ;;
             esac
        }
        _tester_alpha() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information for this command]"
        }
        _tester_beta() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information for this command]"
        }

        """)
    }
    
    func testOptions() {
        let cmd = TestCommand()
        let cli = CLI.createTester(commands: [cmd])
        
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = PipeStream()
        let path = CommandGroupPath(top: cli).appending(cmd)
        generator.writeCommand(for: path, into: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        _tester_test() {
            _arguments -C \\
              '(-s --silent)'{-s,--silent}"[Silence all test output]" \\
              '(-t --times)'{-t,--times}"[Number of times to run the test]" \\
              '(-h --help)'{-h,--help}"[Show help information for this command]"
        }
        
        """)
    }
    
    func testFull() {
        let cli = CLI.createTester(commands: [alphaCmd, betaCmd, intraGroup])
        
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = PipeStream()
        generator.writeCompletions(into: capture)
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        #compdef tester
        _tester() {
            local context state line
            if (( CURRENT > 2 )); then
                (( CURRENT-- ))
                shift words
                _call_function - "_tester_${words[1]}" || _nothing
            else
                __tester_commands
            fi
        }
        __tester_commands() {
             _arguments -C \\
               ': :->command'
             case "$state" in
                  command)
                       local -a commands
                       commands=(
                       alpha"[The alpha command]"
                       beta"[A beta command]"
                       intra"[The intra level of commands]"
                       )
                       _values 'command' $commands
                       ;;
             esac
        }
        _tester_alpha() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information for this command]"
        }
        _tester_beta() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information for this command]"
        }
        _tester_intra() {
            local context state line
            if (( CURRENT > 2 )); then
                (( CURRENT-- ))
                shift words
                _call_function - "_tester_intra_${words[1]}" || _nothing
            else
                __tester_intra_commands
            fi
        }
        __tester_intra_commands() {
             _arguments -C \\
               ': :->command'
             case "$state" in
                  command)
                       local -a commands
                       commands=(
                       charlie"[A beta command]"
                       delta"[A beta command]"
                       )
                       _values 'command' $commands
                       ;;
             esac
        }
        _tester_intra_charlie() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information for this command]"
        }
        _tester_intra_delta() {
            _arguments -C \\
              '(-h --help)'{-h,--help}"[Show help information for this command]"
        }
        _tester
        
        """)
    }
    
}

