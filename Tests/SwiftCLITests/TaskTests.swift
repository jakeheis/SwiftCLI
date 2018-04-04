//
//  TaskTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 4/1/18.
//

import Foundation
import SwiftCLI
import XCTest

class TaskTests: XCTestCase {
    
    static var allTests : [(String, (TaskTests) -> () throws -> Void)] {
        return [
            ("testExec", testExec),
            ("testCapture", testCapture),
            ("testExecutableFind", testExecutableFind),
            ("testBashExec", testBashExec),
            ("testBashCapture", testBashCapture),
            ("testIn", testIn),
            ("testPipe", testPipe),
            ("testCurrentDirectory", testCurrentDirectory),
            ("testEnv", testEnv),
            ("testSignals", testSignals)
        ]
    }
    
    func testExec() throws {
        let file = "file.txt"
        try SwiftCLI.run("/usr/bin/touch", file)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        try FileManager.default.removeItem(atPath: file)
    }
    
    func testCapture() throws {
        let output = try capture("/bin/ls", "Sources")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testExecutableFind() throws {
        XCTAssertEqual(Task.findExecutable(named: "ls"), "/bin/ls")
        
        let output = try capture("ls", "Sources")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testBashExec() throws {
        let file = "file.txt"
        try SwiftCLI.run(bash: "touch \(file)")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        try FileManager.default.removeItem(atPath: file)
    }
    
    func testBashCapture() throws {
        let output = try capture(bash: "ls Sources")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testIn() throws {
        let input = PipeStream()
        
        let output = PipeStream()
        let task = Task(executable: "/usr/bin/sort", stdout: output, stdin: input)
        task.runAsync()
        
        input <<< "beta"
        input <<< "alpha"
        input.closeWrite()
        
        let code = task.finish()
        XCTAssertEqual(code, 0)
        XCTAssertEqual(output.readAll(), "alpha\nbeta\n")
    }
    
    func testPipe() {
        let connector = PipeStream()
        let output = PipeStream()
        
        let ls = Task(executable: "ls", args: ["Tests"], stdout: connector)
        let grep = Task(executable: "grep", args: ["Swift"], stdout: output, stdin: connector)
        
        ls.runAsync()
        grep.runAsync()
                
        XCTAssertEqual(output.readAll(), "SwiftCLITests\n")
    }
    
    func testCurrentDirectory() {
        let capture = PipeStream()
        
        let ls = Task(executable: "ls", currentDirectory: "Sources", stdout: capture)
        ls.runSync()
        
        XCTAssertEqual(capture.readAll(), "SwiftCLI\n")
    }
    
    func testEnv() {
        let capture = PipeStream()
        
        let echo = Task(executable: "bash", args: ["-c", "echo $MY_VAR"], stdout: capture)
        echo.env["MY_VAR"] = "aVal"
        echo.runSync()
        
        XCTAssertEqual(capture.readAll(), "aVal\n")
    }
    
    func testSignals() {
        let task = Task(executable: "/bin/sleep", args: ["1"])
        task.runAsync()
        
        XCTAssertTrue(task.suspend())
        sleep(2)
        XCTAssertTrue(task.isRunning)
        XCTAssertTrue(task.resume())
        sleep(2)
        XCTAssertFalse(task.isRunning)
        
        let task2 = Task(executable: "/bin/sleep", args: ["3"])
        task2.runAsync()
        task2.interrupt()
        XCTAssertEqual(task2.finish(), 2)
        
        let task3 = Task(executable: "/bin/sleep", args: ["3"])
        task3.runAsync()
        task3.terminate()
        XCTAssertEqual(task3.finish(), 15)
    }
    
}
