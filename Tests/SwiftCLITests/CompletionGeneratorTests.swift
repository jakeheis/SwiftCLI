//
//  CompletionGeneratorTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 9/10/17.
//

import XCTest
@testable import SwiftCLI

class CompletionGeneratorTests: XCTestCase {
    
    static var allTests : [(String, (CompletionGeneratorTests) -> () throws -> Void)] {
        return [
            ("testEntryFunction", testEntryFunction),
            ("testTopLevel", testTopLevel),
        ]
    }
    
    func testEntryFunction() {
        let cli = CLI(name: "tester", commands: [])
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = CaptureStream()
        generator.writeEntryFunction(into: capture)
        XCTAssertEqual(capture.content, """
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

        """)
    }
    
    func testTopLevel() {
        let cli = CLI(name: "tester", commands: [alphaCmd, betaCmd])
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = CaptureStream()
        generator.writeTopLevel(into: capture)
        XCTAssertEqual(capture.content, """
        __tester_commands() {
             _arguments -C \\
               ': :->command'
             case "$state" in
                  command)
                       local -a commands
                       commands=(
                       alpha'[The alpha command]'
                       beta'[A beta command]'
                       help'[Prints this help information]'
                       )
                       _values 'command' $commands
                       ;;
             esac
        }
        
        """)
    }
    
    func testOptions() {
        let cli = CLI(name: "tester", commands: [])
        let generator = ZshCompletionGenerator(cli: cli)
        let capture = CaptureStream()
        generator.writeCommand(TestCommand(), into: capture)
        XCTAssertEqual(capture.content, """
        _tester_test() {
            _arguments -C \\
              '(-s --silent)'{-s,--silent}'[Silence all test output]' \\
              '(-t --times)'{-t,--times}'[Number of times to run the test]' \\
              '(-h --help)'{-h,--help}'[Show help information for this command]'
        }
        
        """)
    }
    
    func testFull() {
        let cli = CLI(name: "tester", commands: [alphaCmd, betaCmd])
        let generator = ZshCompletionGenerator(cli: cli)
        generator.writeCompletions(into: StdoutStream())
    }
    
}

